package com.lsi.server.repository;

import java.util.Optional;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.Stat;

@Repository
public interface StatRepository extends JpaRepository<Stat, Long> {

	@Query("SELECT s FROM Stat s where s.question.id = :questionId and s.user.id = :userId")
	Optional<Stat> findStatByQuestionAndUser(@Param("questionId") Long questionId, @Param("userId") Long userId);

	@Query("SELECT s FROM Stat s where s.question.id = :questionId")
	List<Stat> findStatsByQuestionId(@Param("questionId") Long questionId);

	@Query("SELECT s FROM Stat s where s.user.id = :userId")
	List<Stat> findStatsByUserId(@Param("userId") Long userId);
}
