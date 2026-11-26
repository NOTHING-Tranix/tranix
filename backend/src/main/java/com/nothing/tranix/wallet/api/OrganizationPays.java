package com.nothing.tranix.wallet.api;

import java.util.UUID;

/**
 * B-1608: a driver who belongs to an Organization has no wallet of their own — the Organization's wallet pays their
 * trip charges (spec §4, §17). Implemented by the fleet module (which already depends on wallet), so the wallet can
 * refuse an own wallet / top-up for such drivers without depending on fleet.
 */
public interface OrganizationPays {

    /** True when this driver's trip charges are paid by an Organization. */
    boolean forDriver(UUID driverId);
}
