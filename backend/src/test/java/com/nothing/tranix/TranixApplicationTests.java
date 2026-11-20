package com.nothing.tranix;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

@IntegrationTest
class TranixApplicationTests {

    @Autowired
    JdbcTemplate jdbc;

    @Test
    void contextLoadsAndFlywayMigrates() {
        Integer settings = jdbc.queryForObject("select count(*) from admin_setting", Integer.class);
        assertThat(settings).isGreaterThan(30);
    }
}
