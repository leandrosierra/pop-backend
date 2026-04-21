package com.lsi.server.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.Stat;

@Repository
public interface StatRepository extends JpaRepository<Stat, Long> {

}
