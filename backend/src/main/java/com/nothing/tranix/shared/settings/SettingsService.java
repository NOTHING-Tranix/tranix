package com.nothing.tranix.shared.settings;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;


import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Loads all settings once and serves typed values from memory until {@link #reload()}. */
@Service
class SettingsService implements Settings {

    private final AdminSettingRepository repository;
    private volatile Map<String, AdminSetting> cache;

    SettingsService(AdminSettingRepository repository) {
        this.repository = repository;
    }

    @Override
    public int getInt(String key) {
        return Integer.parseInt(raw(key, AdminSetting.Type.INT).trim());
    }

    @Override
    public BigDecimal getDecimal(String key) {
        AdminSetting s = setting(key);
        if (s.type() != AdminSetting.Type.DECIMAL && s.type() != AdminSetting.Type.INT) {
            throw wrongType(key, AdminSetting.Type.DECIMAL, s.type());
        }
        return new BigDecimal(s.value().trim());
    }

    @Override
    public boolean getBoolean(String key) {
        return Boolean.parseBoolean(raw(key, AdminSetting.Type.BOOLEAN).trim());
    }

    @Override
    public String getString(String key) {
        return raw(key, AdminSetting.Type.STRING);
    }

    @Override
    public List<Integer> getIntList(String key) {
        return split(raw(key, AdminSetting.Type.INT_LIST)).stream().map(Integer::parseInt).toList();
    }

    @Override
    public List<String> getStringList(String key) {
        return split(raw(key, AdminSetting.Type.STRING_LIST));
    }

    @Override
    public void reload() {
        cache = null;
    }

    private String raw(String key, AdminSetting.Type expected) {
        AdminSetting s = setting(key);
        if (s.type() != expected) {
            throw wrongType(key, expected, s.type());
        }
        return s.value();
    }

    private AdminSetting setting(String key) {
        AdminSetting s = all().get(key);
        if (s == null) {
            throw new IllegalStateException("Unknown setting: " + key);
        }
        return s;
    }

    @Transactional(readOnly = true)
    Map<String, AdminSetting> all() {
        Map<String, AdminSetting> current = cache;
        if (current == null) {
            current = repository.findAll().stream()
                    .collect(Collectors.toUnmodifiableMap(AdminSetting::key, Function.identity()));
            cache = current;
        }
        return current;
    }

    private static List<String> split(String value) {
        return Arrays.stream(value.split(",")).map(String::trim).filter(v -> !v.isEmpty()).toList();
    }

    private static IllegalStateException wrongType(String key, AdminSetting.Type expected, AdminSetting.Type actual) {
        return new IllegalStateException("Setting " + key + " is " + actual + ", not " + expected);
    }
}
