package com.nothing.tranix.identity.internal;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import com.nothing.tranix.shared.types.DocumentType;
import com.nothing.tranix.shared.types.Role;

/**
 * B-111: weighted completion items per role (D-23, assumed by Claude). Common: name 10, photo 10, address 15,
 * ID proof 25. Role part totals 40.
 */
final class ProfileCompletion {

    static final Set<DocumentType> ID_PROOFS =
            Set.of(DocumentType.AADHAAR_OFFLINE, DocumentType.PAN, DocumentType.VOTER_ID, DocumentType.DRIVING_LICENCE);

    record Item(String key, String label, boolean done, int weight) {
    }

    record Input(Role role, boolean hasName, boolean hasPhoto, boolean hasAddress, boolean hasRoleProfile,
                 Set<DocumentType> documents) {
    }

    private ProfileCompletion() {
    }

    static List<Item> items(Input in) {
        List<Item> items = new ArrayList<>();
        items.add(new Item("NAME", "Name", in.hasName(), 10));
        items.add(new Item("PHOTO", "Photo", in.hasPhoto(), 10));
        items.add(new Item("ADDRESS", "Address", in.hasAddress(), 15));
        boolean idProof = in.documents().stream().anyMatch(ID_PROOFS::contains);
        items.add(new Item("ID_PROOF", "ID proof", idProof, 25));
        switch (in.role()) {
            case LOAD_PROVIDER, RECEIVER -> items.add(new Item("ROLE_PROFILE", "Account details", in.hasRoleProfile(), 40));
            case FARMER_NETWORK -> {
                items.add(new Item("ROLE_PROFILE", "Network details", in.hasRoleProfile(), 20));
                items.add(new Item("FN_REGISTRATION_CERT", "Registration certificate",
                        in.documents().contains(DocumentType.FN_REGISTRATION_CERT), 20));
            }
            case DRIVER -> {
                items.add(new Item("ROLE_PROFILE", "Licence details", in.hasRoleProfile(), 15));
                items.add(new Item("DRIVING_LICENCE", "Driving licence photo",
                        in.documents().contains(DocumentType.DRIVING_LICENCE), 25));
            }
            case ORGANIZATION -> {
                items.add(new Item("ROLE_PROFILE", "Organization details", in.hasRoleProfile(), 20));
                items.add(new Item("ORG_REGISTRATION_CERT", "Registration certificate",
                        in.documents().contains(DocumentType.ORG_REGISTRATION_CERT), 20));
            }
            case ADMIN -> {
            }
        }
        return items;
    }

    static int percent(List<Item> items) {
        int total = items.stream().mapToInt(Item::weight).sum();
        int done = items.stream().filter(Item::done).mapToInt(Item::weight).sum();
        return total == 0 ? 100 : Math.round(done * 100f / total);
    }
}
