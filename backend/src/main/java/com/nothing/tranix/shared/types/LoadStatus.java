package com.nothing.tranix.shared.types;

/** Contract enum (docs/api-contract.md §2). Do not rename values. */
public enum LoadStatus {
    NOT_ACCEPTED, ACCEPTED, AMOUNT_NEGOTIATION, WAITING_FOR_PICKUP, LOCATION_REACHED, PICKED_UP, TRAVELING, ARRIVED_DESTINATION, DELIVERED, CANCELLED
}
