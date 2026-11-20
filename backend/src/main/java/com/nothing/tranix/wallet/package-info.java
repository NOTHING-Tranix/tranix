/**
 * Append-only wallet ledger, charges, top-up links, gateway webhook, statements.
 * <p>Layout: {@code api} (public interfaces + DTOs), {@code internal} (entities, repositories, services),
 * {@code web} (controllers). Other modules use only {@code api} or application events.
 */
@org.springframework.modulith.ApplicationModule
package com.nothing.tranix.wallet;
