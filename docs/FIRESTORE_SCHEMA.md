# Triply Firestore Schema (implemented)

> Implemented in source on 2026-10-09 (branch `Back-end`). Firebase project:
> `triply-f9b82`. Auth = Firebase Auth (UID is the stable key everywhere).
> Rules: `firestore.rules` (NOT DEPLOYED). Indexes: `firestore.indexes.json`.

## Collections

### `users/{uid}` — profile + role display (Auth owns credentials)
| field | type | notes |
|---|---|---|
| `fullName` (`name` legacy read) | string | set at signup / profile edit |
| `email` | string | |
| `phone` | string | |
| `role` | `tourist`\|`guide`\|`admin` | set once at signup; clients can never write `admin`, never change role afterwards (rules) |
| `avatarUrl` | string | |
| `isActive` | bool | server-owned, default true |
| `createdAt`/`updatedAt` | Timestamp | server timestamps |
| `verification` (LEGACY map) | map | kept for the existing dashboard banner; canonical data is in `guideVerifications` |

### `guideProfiles/{uid}` (uid == `users/{uid}`)
`displayName`, **`contactPhone`** (intentionally PUBLIC: powers the
trip-details guide-contact row; guides supply both at signup. Docs predating
them need the backfill in `DEPLOYMENT_CHECKLIST.md` §5), about, location
(string); languages (string[]); specialty (string);
`pricePerHour` (number, private-booking base); currency (string, default `$`
to match the Guides list display rule); coverUrl; `ratingAvg`/`ratingCount`
(Function-owned); `isVerified`/`canPublishTrips` (Function-owned);
createdAt/updatedAt. Clients write only the public subset (`toClientMap`).
First-time creates may omit server-owned fields (rules default them).

### `guideVerifications/{guideId}` (stable id = guideId, idempotent resubmit)
guideId, idDocumentUrl, licenseDocumentUrl (Cloudinary URLs — references only,
never bytes), status `pending|approved|rejected`, submittedAt (server),
reviewerId, reviewedAt, rejectionReason. Owner creates/reads own pending only
with an exact key allowlist; owner may RE-SUBMIT `rejected → pending`
(same allowlist, stale reviewer fields dropped); decisions are Function-only
(`decideVerification`, which preserves submitted URLs in the legacy mirror).

### `places/{placeId}` (stable mock IDs reused: `giza_pyramids`, …)
name, city, country, category (lowercased), type, address, `geo` (GeoPoint,
queryable) + `latitude`/`longitude` (numbers, for existing `Place.fromJson`
compat), rating, reviewsCount, shortDescription, about, highlights[],
imageUrl + imageUrls[], `nameLower`/`cityLower` (prefix search), timestamps.

### `trips/{tripId}` — ONE record for tourist + guide views
guideId (owner; rules require the creator's `users` role to be `guide`),
guideName (denormalized), placeId, title (+`titleLower`, non-empty enforced),
description, location, dateLabel, startTime, duration, priceEgp (>= 0 enforced),
currency, capacity (int >= 1 enforced), **`bookedSeats`** (Function-owned
counter), peopleCount (legacy), meetingPoint, included[], highlights[],
itinerary[] (`{time,title}`), notes[], languages[] (string or single string
legacy), coverImageUrl, imageUrls[], category, **`approvalStatus`**
`pending|approved|rejected|cancelled` (Function/admin-owned), rejectionReason,
timestamps.
- Tourists query `approvalStatus==approved`; guides query `guideId==me`;
  admin reviews `approvalStatus==pending`. Rules + `decideTripStatus` enforce.
- Decided rule: edits to `priceEgp`/`capacity`/`dateLabel` on an APPROVED trip
  re-pend it (`onTripUpdated` trigger + guide notice); editorial fixes stay live.

### `bookings/{bookingId}` — public + private in one collection
touristId, bookingType `public|private`, tripId (public), guideId,
placeId (private), `tripDate`/`appointmentAt` (when it happens — distinct from
`createdAt` when it was booked), timeSlot, seats (== travelers for private),
durationHours (private), unitPrice/serviceFee/totalAmount/currency
(**Function-computed**, never client totals), status
`pending|confirmed|completed|cancelled`, paymentStatus
`pending|succeeded|failed|refunded`, paymentId, meetingPoint,
specialRequests, **`idempotencyKey`** (duplicate-submit guard, ledger in
**`bookingKeys/{key}`** — `{bookingId, touristId, fp}`, Function-only, deny-all
rules; `fp` is a SHA-256 fingerprint of the material request fields, so a
same-key retry with different details is rejected instead of resolving to an
unrelated booking), cancelledAt/cancelReason, `refundStatus` (`owed|none`) +
`refundAmount` (bookkeeping only — no money moves; refund POLICY undecided),
`capacityReleased` (trigger marker, Function-only), timestamps.
- Created ONLY by `createBooking` (transaction + pricing). Tourist may only
  flip own UNPAID active booking to `cancelled` (capacity released by trigger);
  paid cancels go through the `cancelBooking` callable.

### `payments/{paymentId}` (1—1 with booking)
bookingId, touristId, provider (`paymob`), providerReference (Paymob order id),
paymentTokenRef (key id, NOT the secret), amount, currency, status
`pending|succeeded|failed|refunded`, createdAt/updatedAt/verifiedAt.
Clients create `pending` only; ONLY `verifyPaymobTransaction` escalates.
**Never PAN/CVV** (no such fields exist by design).

### `posts/{postId}` + `posts/{postId}/likes/{uid}`
authorId/authorName/authorAvatarUrl (denormalized), text, imageUrls[] (+legacy
`imageUrl` mirror), location, likesCount/commentsCount (**Function-owned**),
timestamps. Likes are one doc per uid (ownership-safe); `onPostLikeWritten`
aggregates the count.

### `stories/{storyId}`
userId, userName, mediaUrl, isVideo, createdAt, **`expiresAt`** (**Timestamp**,
`= createdAt+24h` client-clock; string expiries are rejected by rules and
invisible to queries/cleanup — pre-fix ISO-string docs need the backfill in
`DEPLOYMENT_CHECKLIST.md` §5).
Queries filter `expiresAt > now`; `cleanupExpiredStories` (daily, Africa/Cairo)
hard-deletes expired docs. Owner/admin early delete allowed.

### `notifications/{notificationId}`
userId (**recipient**), title, message, type, relatedEntityId/relatedCollection,
isRead, createdAt. Created ONLY by Functions (booking/trip/verification/payment
events); recipient may only flip `isRead`.

### `reviews/{tripId_touristId}` (roadmap — no review UI exists yet)
tripId, touristId, guideId, rating 1..5 (clamped), comment, timestamps.
`onReviewWritten` maintains trip + guide aggregates.

### `appSettings/{settingId}` (operational only — theme stays in Flutter)
Known keys: `serviceFeeRate` (0.05), `privateServiceFeeRate` (0.05),
`currency` (EGP), `maintenanceMode` (false), `minAppVersion` (1.0.0).
Read public; write admin-only. `OperationalSettings.fromDocs` supplies
offline-safe defaults.

### `admins/{uid}` (presence docs)
Empty-ish docs (`provisionedBy`, `provisionedAt`) marking authorized admins.
Written via Console/`provisionAdmin` only — never from clients.

## Relationships
- `users/{uid}` 1—1 `guideProfiles/{uid}`; 1—N `guideVerifications`
  (stable id collapses to 1 active), `trips` (via `guideId`), `bookings`
  (via `touristId`), `posts`/`stories`/`notifications`/`reviews`/`payments`.
- `places/{id}` 1—N `trips` (via `placeId`).
- `trips/{id}` 1—N `bookings` (via `tripId`); capacity = `capacity-bookedSeats`.
- `bookings/{id}` 1—1 `payments` (via `bookingId`).

## Data flows (all roles share the same docs)
- Guide creates trip (`GuideTripsRepository.createTrip` → `trips/`, pending) →
  `onTripCreated` normalizes + notifies guide → admin sees it in
  `listPending` → `decideTripStatus(approved)` → tourists see it in
  `listApproved` → tourist book → `createBooking` (tx + pricing, `bookedSeats++`,
  notifies guide) → Paymob iframe → `createPendingPayment` → `verifyPaymobTransaction`
  (succeeded → booking confirmed, notifies tourist) → tourist cancels →
  rules allow `cancelled` → `onBookingStatusChanged` releases capacity +
  notifies guide.
- Guide verification: `submitVerificationDocuments` (legacy `users` map +
  canonical `guideVerifications/`) → admin `decideVerification` → flips
  `guideProfiles` flags + legacy mirror + notifies guide → dashboard banner
  hides.
- Community: `CommunityRepository` CRUD + persistent likes; admin deletes any
  post (rules). Notifications: Function-created, recipient mark-read
  (`NotificationsRepository`).
- Admin reads/writes go through the same collections (`decide*` callables +
  direct reads with `AdminAccessService.isAuthorized`); NOT local mock lists.
