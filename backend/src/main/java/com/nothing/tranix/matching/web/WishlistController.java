package com.nothing.tranix.matching.web;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.matching.internal.WishlistService;
import com.nothing.tranix.shared.security.CurrentUser;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Contract §6A — wish list (LOAD_PROVIDER, FARMER_NETWORK). */
@RestController
@RequestMapping("/api/v1/wishlist")
class WishlistController {

    private final WishlistService wishlist;

    WishlistController(WishlistService wishlist) {
        this.wishlist = wishlist;
    }

    record Add(@NotBlank String targetType, UUID truckId, UUID orgId, @Size(max = 200) String note) {
    }

    record Note(@Size(max = 200) String note) {
    }

    @GetMapping
    List<Map<String, Object>> list() {
        return wishlist.list(CurrentUser.id());
    }

    @PostMapping
    Map<String, Object> add(@Valid @RequestBody Add req) {
        return wishlist.add(CurrentUser.id(), req.targetType(), req.truckId(), req.orgId(), req.note());
    }

    @PutMapping("/{id}")
    Map<String, Object> update(@PathVariable UUID id, @Valid @RequestBody Note req) {
        return wishlist.updateNote(CurrentUser.id(), id, req.note());
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void remove(@PathVariable UUID id) {
        wishlist.remove(CurrentUser.id(), id);
    }

    @GetMapping("/org-search")
    List<Map<String, Object>> orgSearch(@RequestParam(required = false) String q) {
        return wishlist.orgSearch(CurrentUser.id(), q);
    }

    @GetMapping("/candidates")
    List<Map<String, Object>> candidates() {
        return wishlist.candidates(CurrentUser.id());
    }
}
