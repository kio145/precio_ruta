import { onRequest } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';

import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import {
  getFirestore,
  GeoPoint,
  DocumentReference,
} from 'firebase-admin/firestore';

initializeApp();
const db = getFirestore();

interface CartItemPayload {
  name?: string;
  qty?: number;
  unitPrice?: number;
  pharmacyLabel?: string;
  pharmacySlug?: string;
  productPath?: string; // 'products/001' etc.
}

interface Recommendation {
  itemName: string;
  currentPharmacy?: string;
  currentPharmacySlug?: string;
  currentUnitPrice: number;
  qty: number;
  bestUnitPrice: number;
  bestPharmacyPath: string;
  bestPharmacyName: string;
  bestPharmacySlug?: string;
  bestBranchName?: string;
  distanceKm?: number | null;
  totalCurrent: number;
  totalBest: number;
  savings: number;
}

// Haversine para distancia en km (si luego mandas lat/lng)
function haversineKm(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371; // km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Helper para devolver un nombre "bonito" de farmacia
function prettyFarmName(
  farmData: any | undefined,
  slug?: string
): string {
  // 1) Intentar leer campos de texto del documento
  const direct =
    farmData?.nombre_comercial ??  // <-- tu campo real
    farmData?.nombre ??
    farmData?.name ??
    farmData?.label ??
    farmData?.razonSocial;

  if (direct && typeof direct === 'string') {
    return direct;
  }

  // 2) Intentar mapear por slug conocido
  const s = (slug ?? '').toString().toLowerCase();
  if (s === 'farmacorp') return 'Farmacorp';
  if (s === 'farmacias-chavez') return 'Farmacias Chávez';
  if (s === 'farmacia-hipermaxi') return 'Hipermaxi';

  // 3) Fallback genérico, SIN mostrar IDs raros
  return 'una de las farmacias registradas';
}

export const aiCartAdvice = onRequest(
  {
    region: 'us-central1',
  },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('Method not allowed');
      return;
    }

    try {
      // --- Verificar token Firebase (por si quieres usarlo para algo interno) ---
      const authHeader = req.headers.authorization || '';
      const token = authHeader.startsWith('Bearer ')
        ? authHeader.substring(7)
        : null;

      let uid: string | null = null;
      if (token) {
        try {
          const decoded = await getAuth().verifyIdToken(token);
          uid = decoded.uid;
        } catch (err) {
          logger.warn('Token Firebase inválido o expirado', err as any);
        }
      }

      // Usamos uid solo para logging, así no da error TS de variable no usada
      logger.info(`aiCartAdvice invocado por uid=${uid ?? 'anonimo'}`);

      const body = req.body as any;
      const rawItems: CartItemPayload[] = Array.isArray(body.items)
        ? body.items
        : [];

      // Si luego quieres cercanía, puedes mandar estos campos desde Flutter
      const userLat = typeof body.userLat === 'number' ? body.userLat : null;
      const userLng = typeof body.userLng === 'number' ? body.userLng : null;
      const hasLocation = userLat !== null && userLng !== null;

      const recommendations: Recommendation[] = [];

      for (const raw of rawItems) {
        const name = raw.name ?? 'Producto';
        const qty = raw.qty ?? 1;
        const currentPrice = raw.unitPrice ?? 0;
        const currentPharmacyLabel = raw.pharmacyLabel ?? '';
        const currentPharmacySlug = (raw.pharmacySlug ?? '').toString();
        const productPath = raw.productPath;

        if (!productPath) {
          logger.warn(
            `Item sin productPath, se omite: ${JSON.stringify(raw)}`
          );
          continue;
        }

        const productRef = db.doc(productPath);

        // 1) Buscar TODOS los skus de ese producto (todas las farmacias)
        const skusSnap = await productRef.collection('skus').get();

        let bestPrice = Number.POSITIVE_INFINITY;
        let bestPharmacyRef: DocumentReference | null = null;

        for (const skuDoc of skusSnap.docs) {
          const data = skuDoc.data() as any;
          const price = data.price as number | undefined;
          const pharmacyRef = data.pharmacyRef as
            | DocumentReference
            | undefined;

          if (typeof price !== 'number' || !pharmacyRef) continue;

          if (price < bestPrice) {
            bestPrice = price;
            bestPharmacyRef = pharmacyRef;
          }
        }

        if (!isFinite(bestPrice) || !bestPharmacyRef) {
          logger.warn(
            `No se encontró sku con precio para ${productPath} (item: ${name})`
          );
          continue;
        }

        // 2) Leer nombre de la farmacia más barata
        const farmSnap = await bestPharmacyRef.get();
        const farmData = farmSnap.data() as any | undefined;
        const bestPharmacySlug: string = (farmData?.slug ?? '')
          .toString()
          .toLowerCase();

        // Usamos el helper para NO mostrar IDs feos
        const bestPharmacyName: string = prettyFarmName(
          farmData,
          bestPharmacySlug
        );

        // 3) (Opcional) sucursal más cercana de esa farmacia
        let bestBranchName: string | undefined;
        let bestDistanceKm: number | null = null;

        if (hasLocation) {
          const sucSnap = await db
            .collection('sucursales')
            .where('farmaciaRef', '==', bestPharmacyRef)
            .get();

          for (const sucDoc of sucSnap.docs) {
            const data = sucDoc.data() as any;
            const geo = data.geo as GeoPoint | undefined;

            if (!geo) continue;

            const d = haversineKm(
              userLat as number,
              userLng as number,
              geo.latitude,
              geo.longitude
            );

            if (bestDistanceKm === null || d < bestDistanceKm) {
              bestDistanceKm = d;
              bestBranchName =
                data.nombre || data.name || `Sucursal ${sucDoc.id}`;
            }
          }
        }

        const totalCurrent = currentPrice * qty;
        const totalBest = bestPrice * qty;

        let savings = 0;
        if (
          bestPharmacySlug &&
          bestPharmacySlug !== currentPharmacySlug &&
          totalBest < totalCurrent
        ) {
          savings = totalCurrent - totalBest;
        }

        recommendations.push({
          itemName: name,
          currentPharmacy: currentPharmacyLabel,
          currentPharmacySlug,
          currentUnitPrice: currentPrice,
          qty,
          bestUnitPrice: bestPrice,
          bestPharmacyPath: bestPharmacyRef.path,
          bestPharmacyName,
          bestPharmacySlug,
          bestBranchName,
          distanceKm: bestDistanceKm,
          totalCurrent,
          totalBest,
          savings,
          productPath,
        } as any);
      }

      if (recommendations.length === 0) {
        res.json({
          message:
            'No se encontraron alternativas más económicas con los datos actuales.',
          recommendations: [],
        });
        return;
      }

      const anySavings = recommendations.some((r) => r.savings > 0);

      if (!anySavings) {
        res.json({
          message:
            'Con los precios actuales no encontramos ninguna farmacia que ofrezca estos productos más baratos que donde ya los tienes en el carrito.',
          recommendations,
        });
        return;
      }

      // Construir mensaje solo con los productos que sí tienen ahorro
      const lines: string[] = [];

      // Encabezado amigable: ya NO mostramos el uid
      lines.push('Análisis del carrito para usted:');

      for (const r of recommendations) {
        if (r.savings <= 0) continue;

        const distanciaText =
          r.distanceKm != null ? ` (~${r.distanceKm.toFixed(1)} km)` : '';

        lines.push(
          `• ${r.itemName}: en tu carrito pagas Bs. ${r.currentUnitPrice.toFixed(
            2
          )} c/u${
            r.currentPharmacy ? ` en ${r.currentPharmacy}` : ''
          }. La opción más barata es Bs. ${r.bestUnitPrice.toFixed(
            2
          )} c/u en ${r.bestPharmacyName}${
            r.bestBranchName ? ` - ${r.bestBranchName}` : ''
          }${distanciaText}. Ahorro aproximado Bs. ${r.savings.toFixed(2)}.`
        );
      }

      const message = lines.join('\n');

      res.json({
        message,
        recommendations,
      });
    } catch (err: any) {
      logger.error('Error en aiCartAdvice', err);
      res.status(500).json({
        message: 'Error al procesar la recomendación de IA basada en datos.',
        error: err?.message ?? String(err),
      });
    }
  }
);
