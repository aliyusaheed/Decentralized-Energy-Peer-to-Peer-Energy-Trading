;; Grid Integration Contract
;; Integrates P2P trading with the main grid

(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_INVALID_CAPACITY (err u301))
(define-constant ERR_GRID_OVERLOAD (err u302))
(define-constant ERR_INSUFFICIENT_GRID_CAPACITY (err u303))

(define-constant GRID_OPERATOR tx-sender)

;; Grid status and capacity
(define-data-var total-grid-capacity-kw uint u10000)
(define-data-var current-grid-load-kw uint u0)
(define-data-var grid-status (string-ascii 10) "normal")

;; Grid connection points
(define-map grid-connections
  { connection-id: uint }
  {
    location: (string-ascii 50),
    capacity-kw: uint,
    current-load-kw: uint,
    connected-producers: (list 10 principal),
    status: (string-ascii 10)
  }
)

(define-data-var next-connection-id uint u1)

;; Energy flow tracking
(define-map energy-flows
  { flow-id: uint }
  {
    from-connection: uint,
    to-connection: uint,
    energy-amount-kwh: uint,
    timestamp: uint,
    flow-type: (string-ascii 10)
  }
)

(define-data-var next-flow-id uint u1)

;; Register grid connection point
(define-public (register-grid-connection (location (string-ascii 50)) (capacity-kw uint))
  (let ((connection-id (var-get next-connection-id)))
    (asserts! (is-eq tx-sender GRID_OPERATOR) ERR_UNAUTHORIZED)
    (asserts! (> capacity-kw u0) ERR_INVALID_CAPACITY)

    (map-set grid-connections
      { connection-id: connection-id }
      {
        location: location,
        capacity-kw: capacity-kw,
        current-load-kw: u0,
        connected-producers: (list),
        status: "active"
      }
    )

    (var-set next-connection-id (+ connection-id u1))
    (ok connection-id)
  )
)

;; Connect producer to grid
(define-public (connect-producer-to-grid (connection-id uint) (producer principal))
  (let ((connection (unwrap! (map-get? grid-connections { connection-id: connection-id }) ERR_INVALID_CAPACITY)))
    (asserts! (is-eq tx-sender GRID_OPERATOR) ERR_UNAUTHORIZED)

    (let ((current-producers (get connected-producers connection)))
      (map-set grid-connections
        { connection-id: connection-id }
        (merge connection { connected-producers: (unwrap-panic (as-max-len? (append current-producers producer) u10)) })
      )
    )

    (ok true)
  )
)

;; Record energy flow
(define-public (record-energy-flow (from-connection uint) (to-connection uint) (energy-amount-kwh uint) (flow-type (string-ascii 10)))
  (let ((flow-id (var-get next-flow-id)))
    (asserts! (is-eq tx-sender GRID_OPERATOR) ERR_UNAUTHORIZED)
    (asserts! (> energy-amount-kwh u0) ERR_INVALID_CAPACITY)

    ;; Check grid capacity
    (let ((current-load (var-get current-grid-load-kw))
          (total-capacity (var-get total-grid-capacity-kw)))
      (asserts! (<= (+ current-load energy-amount-kwh) total-capacity) ERR_GRID_OVERLOAD)

      (map-set energy-flows
        { flow-id: flow-id }
        {
          from-connection: from-connection,
          to-connection: to-connection,
          energy-amount-kwh: energy-amount-kwh,
          timestamp: block-height,
          flow-type: flow-type
        }
      )

      (var-set current-grid-load-kw (+ current-load energy-amount-kwh))
      (var-set next-flow-id (+ flow-id u1))

      (ok flow-id)
    )
  )
)

;; Update grid status
(define-public (update-grid-status (new-status (string-ascii 10)))
  (begin
    (asserts! (is-eq tx-sender GRID_OPERATOR) ERR_UNAUTHORIZED)
    (var-set grid-status new-status)
    (ok new-status)
  )
)

;; Get grid status
(define-read-only (get-grid-status)
  {
    status: (var-get grid-status),
    total-capacity-kw: (var-get total-grid-capacity-kw),
    current-load-kw: (var-get current-grid-load-kw),
    utilization-percent: (/ (* (var-get current-grid-load-kw) u100) (var-get total-grid-capacity-kw))
  }
)

;; Get connection details
(define-read-only (get-grid-connection (connection-id uint))
  (map-get? grid-connections { connection-id: connection-id })
)

;; Get energy flow
(define-read-only (get-energy-flow (flow-id uint))
  (map-get? energy-flows { flow-id: flow-id })
)
