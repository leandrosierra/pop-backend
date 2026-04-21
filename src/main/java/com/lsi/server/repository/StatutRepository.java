package com.lsi.server.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.Statut;

@Repository
public interface StatutRepository extends JpaRepository<Statut, Integer> {

	@Query("SELECT s FROM Statut s where s.code = :code")
	Optional<Statut> findStatutByCode(@Param("code") String code);
}
