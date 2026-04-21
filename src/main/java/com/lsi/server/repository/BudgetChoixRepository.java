package com.lsi.server.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.BudgetChoix;

@Repository
public interface BudgetChoixRepository extends JpaRepository<BudgetChoix, Long> {

	@Query("SELECT c FROM BudgetChoix c where c.budget.id = :budgetId and c.user.id = :userId")
	Optional<BudgetChoix> findChoixByBudgetAndUser(@Param("budgetId") Long budgetId, @Param("userId") Long userId);

	@Query("SELECT c FROM BudgetChoix c where c.user.id = :userId")
	List<BudgetChoix> findChoixByUserId(@Param("userId") Long userId);
}
