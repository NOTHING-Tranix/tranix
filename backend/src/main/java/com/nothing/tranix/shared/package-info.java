/**
 * Cross-cutting building blocks used by every module: ids and base entity, {@code GeoPoint} + Haversine,
 * {@code Clock}, RFC 7807 errors with contract codes, security (JWT), contract enums, file storage and the
 * interfaces of outside services (with fake implementations).
 * <p>Open module: every other module may use any of its packages.
 */
@org.springframework.modulith.ApplicationModule(type = org.springframework.modulith.ApplicationModule.Type.OPEN)
package com.nothing.tranix.shared;
