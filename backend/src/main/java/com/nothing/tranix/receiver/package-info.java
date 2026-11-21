/**
 * Receivers (M12): public tracking links for receivers and farmer senders, the server-rendered link page, delivery
 * receipts, rating and mark-paid from the link, and the registered receiver's app endpoints.
 * <p>Layout: {@code api} (events), {@code internal} (services), {@code web} (controllers). Other modules use only
 * {@code api} or application events.
 */
@org.springframework.modulith.ApplicationModule
package com.nothing.tranix.receiver;
