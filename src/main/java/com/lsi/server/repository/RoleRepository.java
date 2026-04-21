package com.lsi.server.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.Role;

@Repository
public interface RoleRepository extends JpaRepository<Role, Integer> {

	@Query("SELECT r FROM Role r where r.code = :code")
	Optional<Role> findRoleByCode(@Param("code") String code);
}
