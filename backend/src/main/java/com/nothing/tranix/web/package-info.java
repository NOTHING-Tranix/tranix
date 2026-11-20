/**
 * Thymeleaf public pages: /p/track/{token}, /p/wallet/topup.
 * <p>Layout: {@code api} (public interfaces + DTOs), {@code internal} (entities, repositories, services),
 * {@code web} (controllers). Other modules use only {@code api} or application events.
 */
@org.springframework.modulith.ApplicationModule
package com.nothing.tranix.web;
