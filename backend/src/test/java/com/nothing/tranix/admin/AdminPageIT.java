package com.nothing.tranix.admin;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.nothing.tranix.IntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;

/** The admin website is a public static page; the data behind it stays admin-only. */
@IntegrationTest
class AdminPageIT {

    @Autowired
    MockMvc mvc;

    @Test
    void pageIsServedAndApiStaysProtected() throws Exception {
        mvc.perform(get("/admin")).andExpect(status().is3xxRedirection()).andExpect(redirectedUrl("/admin/index.html"));
        mvc.perform(get("/admin/index.html")).andExpect(status().isOk()).andExpect(content().string(containsString("Tranix Admin")));
        mvc.perform(get("/api/v1/admin/dashboard")).andExpect(status().isUnauthorized());
    }
}
