package com.lsi.server.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.BudgetPoste;

@Repository
public interface BudgetPosteRepository extends JpaRepository<BudgetPoste, Long> {

	@Query("SELECT p FROM BudgetPoste p where p.budget.id = :budgetId order by p.libelle asc")
	List<BudgetPoste> findPostesByBudgetId(@Param("budgetId") Long budgetId);
}
