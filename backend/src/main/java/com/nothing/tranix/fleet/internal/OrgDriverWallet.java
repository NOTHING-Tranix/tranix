package com.nothing.tranix.fleet.internal;

import java.util.UUID;

import com.nothing.tranix.wallet.api.OrganizationPays;

import org.springframework.stereotype.Component;

/** B-1608: tells the wallet which drivers are paid for by their Organization. */
@Component
class OrgDriverWallet implements OrganizationPays {

    private final FleetService fleet;

    OrgDriverWallet(FleetService fleet) {
        this.fleet = fleet;
    }

    @Override
    public boolean forDriver(UUID driverId) {
        return fleet.orgOf(driverId).isPresent();
    }
}
