package com.nothing.tranix.shared.settings;

import org.springframework.data.jpa.repository.JpaRepository;

interface AdminSettingRepository extends JpaRepository<AdminSetting, String> {
}
