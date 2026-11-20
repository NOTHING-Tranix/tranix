package com.nothing.tranix.identity.api;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Business actions (post, accept, allocate) need a {@code VERIFIED} account (hard rule 1). Put on a controller
 * method or class; the request fails with {@code 403 NOT_VERIFIED} otherwise.
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresVerified {
}
