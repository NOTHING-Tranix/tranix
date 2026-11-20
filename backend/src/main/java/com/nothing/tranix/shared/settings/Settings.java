package com.nothing.tranix.shared.settings;

import java.math.BigDecimal;
import java.util.List;

/**
 * Typed, cached access to admin settings. Other modules read every tunable value through this interface
 * (never hard-coded). Unknown keys or wrong types fail fast with {@link IllegalStateException}.
 */
public interface Settings {

    int getInt(String key);

    BigDecimal getDecimal(String key);

    boolean getBoolean(String key);

    String getString(String key);

    List<Integer> getIntList(String key);

    List<String> getStringList(String key);

    /** Drops the cache so the next read sees the database (called after an admin change). */
    void reload();
}
