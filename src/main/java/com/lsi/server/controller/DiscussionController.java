package com.lsi.server.controller;

import java.util.Date;
import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.lsi.server.exception.ResourceNotFoundException;
import com.lsi.server.model.Question;
import com.lsi.server.model.QuestionComment;
import com.lsi.server.model.QuestionMeeting;
import com.lsi.server.repository.QuestionCommentRepository;
import com.lsi.server.repository.QuestionMeetingRepository;
import com.lsi.server.repository.QuestionsRepository;
import com.lsi.server.repository.UserRepository;
import com.lsi.server.security.ApiPrincipal;
import com.lsi.server.security.SecurityUtils;

@RestController
@RequestMapping("/discussion")
public class DiscussionController {

	@Autowired
	QuestionCommentRepository commentRepository;

	@Autowired
	QuestionMeetingRepository meetingRepository;

	@Autowired
	QuestionsRepository questionsRepository;

	@Autowired
	UserRepository userRepository;

	@GetMapping("/question/{id}/comments")
	public Page<QuestionComment> getCommentsByQuestion(@PathVariable(value = "id") Long questionId,
			@PageableDefault(size = 10) Pageable pageable) {
		Question question = getReadableQuestion(questionId);
		return commentRepository.findCommentsByQuestionId(question.getId(), pageable);
	}

	@PostMapping("/question/{id}/comment/create")
	public QuestionComment createComment(@PathVariable(value = "id") Long questionId,
			@Valid @RequestBody QuestionComment comment) {
		long userId = SecurityUtils.currentPrincipal().getUserId();
		Question question = getReadableQuestion(questionId);
		comment.setId(null);
		comment.setQuestion(question);
		comment.setUser(userRepository.findById(userId)
				.orElseThrow(() -> new ResourceNotFoundException("User", "id", userId)));
		comment.setDateCreation(new Date());
		if (comment.getParentComment() != null && comment.getParentComment().getId() != null) {
			QuestionComment parent = commentRepository.findById(comment.getParentComment().getId())
					.orElseThrow(() -> new ResourceNotFoundException("QuestionComment", "id", comment.getParentComment().getId()));
			if (parent.getQuestion() == null || parent.getQuestion().getId() != question.getId()) {
				throw new SecurityException("Forbidden");
			}
			comment.setParentComment(parent);
		}
		return commentRepository.save(comment);
	}

	@PutMapping("/comment/update")
	public QuestionComment updateComment(@Valid @RequestBody QuestionComment commentDetails) {
		QuestionComment comment = commentRepository.findById(commentDetails.getId())
				.orElseThrow(() -> new ResourceNotFoundException("QuestionComment", "id", commentDetails.getId()));
		requireOwnerOrAdmin(comment.getUser().getId());
		comment.setContenu(commentDetails.getContenu());
		comment.setDateModification(new Date());
		return commentRepository.save(comment);
	}

	@DeleteMapping("/comment/delete/{id}")
	public ResponseEntity<?> deleteComment(@PathVariable(value = "id") Long commentId) {
		QuestionComment comment = commentRepository.findById(commentId)
				.orElseThrow(() -> new ResourceNotFoundException("QuestionComment", "id", commentId));
		requireOwnerOrAdmin(comment.getUser().getId());
		commentRepository.delete(comment);
		return ResponseEntity.ok().build();
	}

	@GetMapping("/question/{id}/meetings")
	public Page<QuestionMeeting> getMeetingsByQuestion(@PathVariable(value = "id") Long questionId,
			@PageableDefault(size = 10) Pageable pageable) {
		Question question = getReadableQuestion(questionId);
		return meetingRepository.findMeetingsByQuestionId(question.getId(), pageable);
	}

	@PostMapping("/question/{id}/meeting/create")
	public QuestionMeeting createMeeting(@PathVariable(value = "id") Long questionId,
			@Valid @RequestBody QuestionMeeting meeting) {
		long userId = SecurityUtils.currentPrincipal().getUserId();
		Question question = getReadableQuestion(questionId);
		meeting.setId(null);
		meeting.setQuestion(question);
		meeting.setUser(userRepository.findById(userId)
				.orElseThrow(() -> new ResourceNotFoundException("User", "id", userId)));
		meeting.setDateCreation(new Date());
		return meetingRepository.save(meeting);
	}

	@PutMapping("/meeting/update")
	public QuestionMeeting updateMeeting(@Valid @RequestBody QuestionMeeting meetingDetails) {
		QuestionMeeting meeting = meetingRepository.findById(meetingDetails.getId())
				.orElseThrow(() -> new ResourceNotFoundException("QuestionMeeting", "id", meetingDetails.getId()));
		requireOwnerOrAdmin(meeting.getUser().getId());
		meeting.setTypeMeeting(meetingDetails.getTypeMeeting());
		meeting.setTitre(meetingDetails.getTitre());
		meeting.setDescription(meetingDetails.getDescription());
		meeting.setLieu(meetingDetails.getLieu());
		meeting.setUrl(meetingDetails.getUrl());
		meeting.setDateDebut(meetingDetails.getDateDebut());
		meeting.setDateFin(meetingDetails.getDateFin());
		meeting.setDateModification(new Date());
		return meetingRepository.save(meeting);
	}

	@DeleteMapping("/meeting/delete/{id}")
	public ResponseEntity<?> deleteMeeting(@PathVariable(value = "id") Long meetingId) {
		QuestionMeeting meeting = meetingRepository.findById(meetingId)
				.orElseThrow(() -> new ResourceNotFoundException("QuestionMeeting", "id", meetingId));
		requireOwnerOrAdmin(meeting.getUser().getId());
		meetingRepository.delete(meeting);
		return ResponseEntity.ok().build();
	}

	private Question getReadableQuestion(Long questionId) {
		Question question = questionsRepository.findById(questionId)
				.orElseThrow(() -> new ResourceNotFoundException("Question", "id", questionId));
		if (!canReadQuestion(question)) {
			throw new SecurityException("Forbidden");
		}
		return question;
	}

	private boolean canReadQuestion(Question question) {
		ApiPrincipal principal = SecurityUtils.currentPrincipal();
		if (principal.isAdmin()) {
			return true;
		}
		if (question.getUser() != null && question.getUser().getId() == principal.getUserId()) {
			return true;
		}
		return question.getStatut() != null && "ACTIF".equals(question.getStatut().getCode());
	}

	private void requireOwnerOrAdmin(long userId) {
		if (!SecurityUtils.isCurrentUserOrAdmin(userId)) {
			throw new SecurityException("Forbidden");
		}
	}
}
