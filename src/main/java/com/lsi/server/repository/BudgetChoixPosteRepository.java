package com.lsi.server.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.BudgetChoixPoste;

@Repository
public interface BudgetChoixPosteRepository extends JpaRepository<BudgetChoixPoste, Long> {

	@Query("SELECT p FROM BudgetChoixPoste p where p.choix.id = :choixId")
	List<BudgetChoixPoste> findAllocationsByChoixId(@Param("choixId") Long choixId);
}
