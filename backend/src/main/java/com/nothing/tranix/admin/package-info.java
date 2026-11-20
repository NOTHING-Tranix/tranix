/**
 * Admin endpoints, verification queue, decisions, audit log, dashboard, settings.
 * <p>Layout: {@code api} (public interfaces + DTOs), {@code internal} (entities, repositories, services),
 * {@code web} (controllers). Other modules use only {@code api} or application events.
 */
@org.springframework.modulith.ApplicationModule
package com.nothing.tranix.admin;
