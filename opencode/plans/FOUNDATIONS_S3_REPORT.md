# Triply Foundations — Phase S3 Report

**Status:** BLOCKED — rules were changed locally but were **not deployed**.
Firebase CLI authentication expired during the rules-only deployment attempt.
Do **not** start S4.

**Project:** `triply-f9b82` (printed by `firebase use` before deployment).
**Plan:** Firebase Spark; no billing change, Cloud Function, emulator, index
deployment, Firestore data access, or test account/document was used.

## Guard compliance and deployment

| Check | Result |
|---|---|
| Rules backup | PASS — `opencode/plans/rules.before-S3.rules` was copied from the current `firestore.rules` before S3 edits; SHA-256 matched at copy time. |
| Active Firebase project | PASS — `triply-f9b82`. |
| Deployment command | Attempted exactly `firebase deploy --only firestore:rules --project triply-f9b82`; no `--force`, index, or other target. |
| Deployment result | BLOCKED — Firebase CLI returned `Authentication Error: Your credentials are no longer valid. Please run firebase login --reauth`. It did not report a successful release. |
| Firestore data | PASS — none read, created, changed, or deleted. |

To deploy after reauthenticating the Firebase CLI, first verify `firebase use`
again prints `triply-f9b82`, then run only:

`firebase deploy --only firestore:rules --project triply-f9b82`

## Rules changed locally

| Rule | Allowed behavior | Denied behavior |
|---|---|---|
| `bookings` create | A signed-in tourist may create their own booking only when `status` and `paymentStatus` are both `pending`. | An unauthenticated caller, a caller creating for another `touristId`, or a booking initially marked paid/confirmed is denied. |
| `bookings` update — guide branch | The owning guide keeps its existing non-payment update capability. | The guide cannot alter `paymentStatus`, `paymentId`, or `refundStatus`. The admin branch is unchanged. |
| `bookings` update — tourist confirmation | The owning tourist may move exactly `pending/pending` to `confirmed/paid`, with a non-empty string `paymentId`; only `status`, `paymentStatus`, `paymentId`, and `updatedAt` may change. | Any other transition, missing/empty payment ID, or a change to price, seats, tourist/guide IDs, or another booking field is denied. |
| `bookings` update — tourist cancellation | The owning tourist may cancel a `pending` or `confirmed` booking while preserving payment state; they must set a timestamp `cancelledAt`, `cancelledBy: 'tourist'`, and `refundStatus: 'none'` for pending or `'owed'` for paid. Only cancellation fields and `updatedAt` may change. | Cancelling another tourist’s booking, changing a price/seat/user/payment field, using an invalid refund status, or cancelling from another state is denied. |

## Trips seat counter

The existing trip counter branch was deliberately retained exactly as requested:
a signed-in user may change only `bookedSeats` and `updatedAt`, and
`bookedSeats` must remain within `[0, capacity]`.

Rules cannot enforce that a counter delta is no larger than the particular
booking’s `seats`: the trip update has no booking ID and Firestore Rules can
only read a fully specified document path. This limitation is accepted for
the Spark/test-payment app. Separately, client-side rules cannot establish
that a supplied Paymob `paymentId` is genuine; a tourist could fabricate one.
That is also accepted because payments are test-only and there is no trusted
server in this phase.

## Verification

No Admin SDK or emulator was used: Admin SDK requests bypass Firestore Rules,
and the phase forbids the emulator. Therefore the table above describes the
locally authored rule behavior; it is not a live allow/deny test result.

The recorded baseline remains `flutter analyze` 0 errors / 22 info lints and
`flutter test` 75 passing / 1 known template failure. The full Flutter test
rerun remains blocked by the externally locked Flutter SDK, as recorded in
S2b; no new test failure was observed in this phase.

## Manual checklist — pending Khaled

After the rules-only deployment succeeds, use accounts/documents flagged
`isTest: true` and then delete all created test data:

| Check | Status |
|---|---|
| Book a public trip with a card test payment. | pending Khaled |
| Cancel that booking from My Trips. | pending Khaled |
| Create a trip as a guide. | pending Khaled |
| Open the guide’s bookings list. | pending Khaled |

## Rollback

No deployment completed, so there is nothing live to roll back now. If the
rules are deployed later and need rollback, restore
`opencode/plans/rules.before-S3.rules` over `firestore.rules`, confirm
`firebase use` reports `triply-f9b82`, then deploy only
`firestore:rules` without `--force`.

## Test data

No test accounts or Firestore documents were created, read, changed, or
deleted. Nothing needs deletion.
