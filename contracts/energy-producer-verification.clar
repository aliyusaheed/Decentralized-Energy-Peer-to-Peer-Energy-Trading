;; Energy Producer Verification Contract
;; Validates and manages peer-to-peer energy producers

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PRODUCER_EXISTS (err u101))
(define-constant ERR_PRODUCER_NOT_FOUND (err u102))
(define-constant ERR_INVALID_CAPACITY (err u103))

;; Producer data structure
(define-map producers
  { producer-id: principal }
  {
    verified: bool,
    capacity-kw: uint,
    location: (string-ascii 50),
    energy-type: (string-ascii 20),
    registration-block: uint
  }
)

;; Verification status tracking
(define-map verification-requests
  { producer-id: principal }
  {
    requested-at: uint,
    verified-by: (optional principal),
    status: (string-ascii 10)
  }
)

;; Register as energy producer
(define-public (register-producer (capacity-kw uint) (location (string-ascii 50)) (energy-type (string-ascii 20)))
  (let ((producer-id tx-sender))
    (asserts! (> capacity-kw u0) ERR_INVALID_CAPACITY)
    (asserts! (is-none (map-get? producers { producer-id: producer-id })) ERR_PRODUCER_EXISTS)

    (map-set producers
      { producer-id: producer-id }
      {
        verified: false,
        capacity-kw: capacity-kw,
        location: location,
        energy-type: energy-type,
        registration-block: block-height
      }
    )

    (map-set verification-requests
      { producer-id: producer-id }
      {
        requested-at: block-height,
        verified-by: none,
        status: "pending"
      }
    )

    (ok producer-id)
  )
)

;; Verify producer (admin only)
(define-public (verify-producer (producer-id principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? producers { producer-id: producer-id })) ERR_PRODUCER_NOT_FOUND)

    (map-set producers
      { producer-id: producer-id }
      (merge (unwrap-panic (map-get? producers { producer-id: producer-id }))
             { verified: true })
    )

    (map-set verification-requests
      { producer-id: producer-id }
      (merge (unwrap-panic (map-get? verification-requests { producer-id: producer-id }))
             { verified-by: (some tx-sender), status: "verified" })
    )

    (ok true)
  )
)

;; Get producer info
(define-read-only (get-producer (producer-id principal))
  (map-get? producers { producer-id: producer-id })
)

;; Check if producer is verified
(define-read-only (is-verified-producer (producer-id principal))
  (match (map-get? producers { producer-id: producer-id })
    producer (get verified producer)
    false
  )
)
