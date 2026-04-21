package com.lsi.server.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.BudgetImpact;

@Repository
public interface BudgetImpactRepository extends JpaRepository<BudgetImpact, Long> {

	@Query("SELECT i FROM BudgetImpact i where i.poste.id = :posteId")
	List<BudgetImpact> findImpactsByPosteId(@Param("posteId") Long posteId);
}
