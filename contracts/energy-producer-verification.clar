;; Energy Trading Contract
;; Facilitates peer-to-peer energy trading

(use-trait producer-verification-trait .energy-producer-verification.producer-verification-trait)

(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_INVALID_AMOUNT (err u201))
(define-constant ERR_INVALID_PRICE (err u202))
(define-constant ERR_ORDER_NOT_FOUND (err u203))
(define-constant ERR_INSUFFICIENT_BALANCE (err u204))
(define-constant ERR_PRODUCER_NOT_VERIFIED (err u205))

;; Order types
(define-constant ORDER_TYPE_SELL "sell")
(define-constant ORDER_TYPE_BUY "buy")

;; Trading order structure
(define-map trading-orders
  { order-id: uint }
  {
    trader: principal,
    order-type: (string-ascii 4),
    energy-amount-kwh: uint,
    price-per-kwh: uint,
    created-at: uint,
    status: (string-ascii 10),
    matched-with: (optional uint)
  }
)

;; Order counter
(define-data-var next-order-id uint u1)

;; Energy balances
(define-map energy-balances
  { trader: principal }
  { balance-kwh: uint }
)

;; Create sell order
(define-public (create-sell-order (energy-amount-kwh uint) (price-per-kwh uint))
  (let ((order-id (var-get next-order-id))
        (trader tx-sender))

    (asserts! (> energy-amount-kwh u0) ERR_INVALID_AMOUNT)
    (asserts! (> price-per-kwh u0) ERR_INVALID_PRICE)

    ;; Check if trader has enough energy balance
    (let ((current-balance (default-to u0 (get balance-kwh (map-get? energy-balances { trader: trader })))))
      (asserts! (>= current-balance energy-amount-kwh) ERR_INSUFFICIENT_BALANCE)

      (map-set trading-orders
        { order-id: order-id }
        {
          trader: trader,
          order-type: ORDER_TYPE_SELL,
          energy-amount-kwh: energy-amount-kwh,
          price-per-kwh: price-per-kwh,
          created-at: block-height,
          status: "active",
          matched-with: none
        }
      )

      ;; Reserve energy balance
      (map-set energy-balances
        { trader: trader }
        { balance-kwh: (- current-balance energy-amount-kwh) }
      )

      (var-set next-order-id (+ order-id u1))
      (ok order-id)
    )
  )
)

;; Create buy order
(define-public (create-buy-order (energy-amount-kwh uint) (price-per-kwh uint))
  (let ((order-id (var-get next-order-id))
        (trader tx-sender))

    (asserts! (> energy-amount-kwh u0) ERR_INVALID_AMOUNT)
    (asserts! (> price-per-kwh u0) ERR_INVALID_PRICE)

    (map-set trading-orders
      { order-id: order-id }
      {
        trader: trader,
        order-type: ORDER_TYPE_BUY,
        energy-amount-kwh: energy-amount-kwh,
        price-per-kwh: price-per-kwh,
        created-at: block-height,
        status: "active",
        matched-with: none
      }
    )

    (var-set next-order-id (+ order-id u1))
    (ok order-id)
  )
)

;; Match orders (simplified matching)
(define-public (match-orders (sell-order-id uint) (buy-order-id uint))
  (let ((sell-order (unwrap! (map-get? trading-orders { order-id: sell-order-id }) ERR_ORDER_NOT_FOUND))
        (buy-order (unwrap! (map-get? trading-orders { order-id: buy-order-id }) ERR_ORDER_NOT_FOUND)))

    ;; Verify orders are compatible
    (asserts! (is-eq (get order-type sell-order) ORDER_TYPE_SELL) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get order-type buy-order) ORDER_TYPE_BUY) ERR_UNAUTHORIZED)
    (asserts! (>= (get price-per-kwh buy-order) (get price-per-kwh sell-order)) ERR_INVALID_PRICE)
    (asserts! (is-eq (get energy-amount-kwh sell-order) (get energy-amount-kwh buy-order)) ERR_INVALID_AMOUNT)

    ;; Update order statuses
    (map-set trading-orders
      { order-id: sell-order-id }
      (merge sell-order { status: "matched", matched-with: (some buy-order-id) })
    )

    (map-set trading-orders
      { order-id: buy-order-id }
      (merge buy-order { status: "matched", matched-with: (some sell-order-id) })
    )

    ;; Transfer energy to buyer
    (let ((buyer (get trader buy-order))
          (energy-amount (get energy-amount-kwh buy-order))
          (buyer-balance (default-to u0 (get balance-kwh (map-get? energy-balances { trader: buyer })))))

      (map-set energy-balances
        { trader: buyer }
        { balance-kwh: (+ buyer-balance energy-amount) }
      )
    )

    (ok { sell-order-id: sell-order-id, buy-order-id: buy-order-id })
  )
)

;; Get order details
(define-read-only (get-order (order-id uint))
  (map-get? trading-orders { order-id: order-id })
)

;; Get energy balance
(define-read-only (get-energy-balance (trader principal))
  (default-to u0 (get balance-kwh (map-get? energy-balances { trader: trader })))
)

;; Add energy to balance (for producers)
(define-public (add-energy-production (amount-kwh uint))
  (let ((producer tx-sender)
        (current-balance (get-energy-balance producer)))

    (asserts! (> amount-kwh u0) ERR_INVALID_AMOUNT)

    (map-set energy-balances
      { trader: producer }
      { balance-kwh: (+ current-balance amount-kwh) }
    )

    (ok (+ current-balance amount-kwh))
  )
)
