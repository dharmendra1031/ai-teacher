# AI Teacher — Complete Project Specification

**Project type:** Self-hosted realtime AI English-learning application with a realistic consented digital teacher  
**Primary client:** Android mobile application  
**Development branch:** `development`  
**Document role:** यह file पूरे product की single source of truth है—project क्या करेगा, user कैसे use करेगा, modules कैसे काम करेंगे, data कैसे flow होगा और MVP में क्या शामिल/बाहर रहेगा।

## Authoritative documents

1. [`README.md`](README.md) — Complete project specification.
2. [`TECH_STACK.md`](TECH_STACK.md) — Verified technologies, licenses, compatibility and infrastructure constraints.
3. [`DEVELOPMENT_ROADMAP.md`](DEVELOPMENT_ROADMAP.md) — Complete phase-by-phase execution plan.

इन तीन files के बाहर कोई duplicate architecture/roadmap document authoritative नहीं होगा।

---

## 1. Project vision

AI Teacher एक ऐसा mobile application होगा जिसमें learner एक realistic AI English teacher के साथ live voice/video-style conversation करेगा। Teacher user को सुनेगा, उसके level और topic के अनुसार जवाब देगा, महत्वपूर्ण grammar mistakes politely correct करेगा, आवश्यकता होने पर आसान Hindi explanation देगा और session के बाद useful learning report बनाएगा।

यह prerecorded chatbot video या fixed-course player नहीं होगा। यह realtime conversational system होगा जिसमें:

- User microphone से बोलेगा।
- AI speech को text में समझेगा।
- AI teacher context के अनुसार short natural response बनाएगा।
- Response natural voice में generate होगी।
- Consented digital teacher का face voice के साथ lip-sync करेगा।
- User AI के बोलते समय interrupt कर सकेगा।
- Session transcript, selected corrections और progress report सुरक्षित तरीके से manage होंगे।

---

## 2. Problem being solved

कई English learners के पास daily speaking partner नहीं होता। Traditional courses grammar और recorded lessons देते हैं, लेकिन learner को real conversation, immediate correction और confidence practice कम मिलती है। Human tutor useful होता है लेकिन हर समय available नहीं और लगातार sessions महंगे हो सकते हैं।

AI Teacher का उद्देश्य:

- Learner को low-pressure speaking practice देना।
- Daily practice आसान बनाना।
- Beginner के अनुसार slow/simple conversation देना।
- Important mistakes explain करना, हर sentence पर रोकना नहीं।
- Practice को measurable progress में बदलना।
- Human-like presence देना, लेकिन साफ बताना कि सामने AI teacher है।

---

## 3. Target users

### Initial users

- India-based English learners.
- Beginner और intermediate learners.
- Job interview, office communication और daily conversation practice चाहने वाले adults.
- Hindi समझने वाले learners जिन्हें कठिन correction का simple Hindi explanation helpful हो।

### Initial platform

- Android first.
- Physical Android devices mandatory for testing.
- iOS और web initial commercial release का हिस्सा नहीं।

### Age policy

Minor users को accept करने से पहले age policy, parent/guardian consent requirements और India DPDP compliance review पूरा होगा। Closed beta की initial policy adults-only रखी जा सकती है ताकि child-data risk पहले release में control रहे। Final age decision roadmap के Phase 0 में document होगा।

---

## 4. User roles

### Learner

- Register/login करेगा।
- English level और goal चुनेगा।
- Teacher/topic चुनेगा।
- Live practice session शुरू करेगा।
- Mic/camera controls use करेगा।
- Captions और selected corrections देखेगा।
- Session report और previous mistakes review करेगा।
- Progress और practice minutes देखेगा।
- Data/privacy settings manage करेगा।

### Admin/Operations

- Teachers, topics और lesson scenarios manage करेगा।
- Failed sessions और worker status inspect करेगा।
- User limits और feature availability manage करेगा।
- Consent status और avatar asset eligibility verify करेगा।
- Data deletion/export requests process करेगा।
- Usage, cost और error metrics देखेगा।
- Sensitive user content तक default unrestricted access नहीं होगा।

### AI Teacher participant

यह human account नहीं होगा। यह realtime room में controlled AI participant होगा जो:

- User audio subscribe करेगा।
- Turn detection करेगा।
- Speech-to-text, LLM और TTS pipeline चलाएगा।
- AI audio/video publish करेगा।
- Session lifecycle और cancellation rules follow करेगा।

---

## 5. MVP scope

Initial usable MVP में:

1. Android Flutter application.
2. Register, login, refresh token और logout.
3. User profile और English level.
4. One consented AI teacher/avatar.
5. One selected English voice.
6. Beginner और intermediate modes.
7. Limited practice topics.
8. LiveKit-based realtime audio/video room.
9. Realtime speech-to-text.
10. Short AI teacher responses.
11. Text-to-speech.
12. User interruption/barge-in.
13. Speaking avatar with lip-sync.
14. Idle, listening, thinking और ending visual states.
15. Live/final captions.
16. Selected grammar corrections.
17. Session history.
18. Session report.
19. Practice minutes और basic progress.
20. Daily/session duration limits.
21. Admin management for core content and failed sessions.
22. AI disclosure, consent, privacy and deletion flows.
23. Audio-only fallback when avatar worker unavailable.

---

## 6. Features outside the initial MVP

- Multiple teacher avatars.
- Voice cloning.
- Full-body generated human.
- Real-time room/background generation.
- Emotional or psychological diagnosis.
- Unsupported facial-emotion claims.
- Official IELTS/TOEFL certification score.
- Unlimited free video conversations.
- User-created replicas.
- Public-figure faces or voices.
- Group classroom calls.
- iOS and web launch.
- Kubernetes/multi-region infrastructure before measured need.
- Training foundational avatar/LLM models from zero.

इन features को future में केवल real user metrics, consent, legal review, cost benchmark और ADR के बाद consider किया जाएगा।

---

## 7. Main learner journey

```text
Install App
   ↓
AI disclosure + privacy notice
   ↓
Register / Login
   ↓
Select English level and goal
   ↓
Dashboard
   ↓
Select teacher + topic + difficulty
   ↓
Check microphone/camera permissions
   ↓
Create secure practice session
   ↓
Join LiveKit room
   ↓
AI teacher joins
   ↓
Live conversation
   ↓
User ends call or time limit completes
   ↓
Transcript and report processing
   ↓
Corrections + feedback + next practice
   ↓
Progress updated
```

---

## 8. Authentication and onboarding

### Registration

- Name.
- Email/mobile strategy Phase 3 API design में final होगी.
- Password.
- Age-policy acknowledgement.
- Privacy notice and consent version.
- Initial English level.
- Optional learning goal.

### Login/session

- Short-lived access token.
- Rotating refresh token.
- Secure storage on device.
- Logout token revocation.
- Password reset with expiring single-use token.
- Rate limiting and suspicious login audit.

### First-use onboarding

- AI teacher is not a human disclosure.
- Microphone usage explanation.
- Camera is optional if product mode allows; AI avatar still visible.
- Default no raw audio/video recording notice.
- English level selection.
- First practice recommendation.

---

## 9. Dashboard

Dashboard learner को केवल useful actions दिखाएगा:

- Start practice.
- Continue recommended lesson.
- Today's practice minutes.
- Current streak.
- Recent score/feedback summary.
- Mistakes to revise.
- Session history shortcut.
- Account/settings.

Dashboard heavy analytics से भरना नहीं है। Beginner learner को next action clear दिखना चाहिए।

---

## 10. Teacher and topic selection

### Teacher profile

Initial release में one teacher होगा। Profile में:

- Display name.
- AI label.
- Avatar image/preview.
- Voice/language capability.
- Supported levels.
- Active/inactive status.
- Consent and asset status (admin-only).

### Topics

Initial examples:

- Introduce yourself.
- Daily routine.
- Family and friends.
- Shopping.
- Travel.
- Restaurant conversation.
- Office introduction.
- Customer dealing.
- Job interview basics.
- Phone conversation.

Each topic stores:

- Level.
- Learning objective.
- Key vocabulary.
- Scenario instructions.
- Opening prompt.
- Expected conversation length.
- Report rubric version.

---

## 11. Practice-session creation

Flutter backend को start request भेजेगा:

```json
{
  "teacher_id": "teacher-id",
  "topic_id": "topic-id",
  "level": "beginner",
  "mode": "avatar"
}
```

Backend:

1. User authentication verify करेगा।
2. Account status check करेगा।
3. Daily/session limits check करेगा।
4. Teacher/topic availability validate करेगा।
5. One-active-session rule enforce करेगा।
6. Database session `CREATING` state में बनाएगा।
7. Unguessable LiveKit room name बनाएगा।
8. Minimal, short-lived participant token बनाएगा।
9. Named AI agent dispatch करेगा।
10. Session ID, room endpoint और token Flutter को return करेगा।

Session state machine:

```text
CREATING
  ↓
READY
  ↓
CONNECTING
  ↓
ACTIVE
  ↓
ENDING
  ↓
COMPLETED

Possible terminal states:
FAILED / CANCELLED / EXPIRED
```

Every state change idempotent और auditable होगा।

---

## 12. Live-call screen

### Main UI

- AI teacher video full/primary area.
- Small local user camera preview when camera enabled.
- Mic mute/unmute.
- Camera enable/disable and switch.
- Speaker/audio route status.
- End call.
- Network quality/reconnecting state.
- Live caption area.
- Current AI state: listening, thinking, speaking.
- Visible `AI Teacher` disclosure.
- Remaining time when plan/session limit applies.

### UX states

- Permission denied.
- Connecting.
- Waiting for AI teacher.
- Active/listening.
- AI thinking.
- AI speaking.
- User interruption.
- Network reconnecting.
- Avatar unavailable: audio-only fallback.
- Session ending.
- Session failed with safe retry/back action.

User को technical model/GPU errors नहीं दिखेंगे; clear human-readable message मिलेगा।

---

## 13. Realtime conversation behavior

### User turn

1. User speaks.
2. Voice activity detection speech start/end identify करता है।
3. Audio normalize/resample होता है।
4. Speech-to-text partial captions भेजता है।
5. End of turn पर final transcript बनता है।
6. Current turn ID assign होता है।

### AI turn

1. Final transcript teacher policy को भेजा जाता है।
2. LLM short structured response बनाता है।
3. Schema validate होता है।
4. Spoken reply TTS chunks में generate होती है।
5. Audio LiveKit track पर publish होती है।
6. Avatar worker lip-synced speaking frames publish करता है।
7. Correction/report data current turn से associate होता है।

### Interruption/barge-in

जब user AI के बोलते समय बोलता है:

- Current AI turn cancelled होगा।
- Remaining LLM output discarded होगा।
- TTS generation and queued audio stop होंगे।
- Avatar speaking queue flush होगी।
- Teacher listening visual state पर जाएगा।
- Old/stale answer बाद में नहीं बोलेगा।

Every turn unique ID और cancellation token use करेगा।

---

## 14. AI teacher behaviour

Teacher:

- User level के अनुसार vocabulary और speed रखेगा।
- One question at a time पूछेगा।
- Spoken replies short रखेगा।
- Learner को ज्यादा बोलने देगा।
- हर छोटी mistake पर interrupt नहीं करेगा।
- Meaning-changing या lesson-relevant mistakes correct करेगा।
- Correction respectful रखेगा।
- Beginner के लिए optional simple Hindi explanation देगा।
- Unsafe/inappropriate requests पर safe boundary रखेगा।
- Official examination result या medical assessment claim नहीं करेगा।
- Conversation topic से controlled deviation handle करेगा।
- Repetitive responses avoid करेगा।

Internal turn schema example:

```json
{
  "spoken_reply": "What did you buy at the market?",
  "correction": {
    "original": "I go market yesterday",
    "corrected": "I went to the market yesterday.",
    "explanation_hi": "Yesterday के कारण past tense आएगा।"
  },
  "should_end": false
}
```

Invalid structured output direct speech में नहीं जाएगा। Repair/fallback response होगा।

---

## 15. Avatar behaviour

Initial avatar system:

```text
Idle       -> consented loop
Listening  -> consented loop
Thinking   -> consented loop
Speaking   -> realtime MuseTalk lip-sync
Ending     -> consented loop
```

### Requirements

- Only written-consent actor media.
- Stable identity.
- Natural transition between loops and speaking frames.
- Audio is primary synchronization clock.
- Frame buffers bounded होंगे।
- Interruption पर speaking generation cancel होगी।
- Avatar worker fail होने पर call audio-only mode में continue कर सकेगी।
- App हमेशा AI identity disclose करेगा।

### Not promised

Initial beta Tavus-level perfect realism की guarantee नहीं देगा। Known mouth/teeth, jitter और identity-detail artifacts benchmark और beta feedback में documented होंगे।

---

## 16. Captions and corrections

### Live captions

- Partial captions temporary होंगी।
- Final captions sequence-controlled होंगी।
- Out-of-order captions ignore होंगे।
- AI captions optional/visible setting हो सकती है।

### Corrections

During session:

- Only important correction shown/spoken.
- Correction must not continuously block conversation.
- User can continue speaking.

After session:

- Original sentence.
- Correct sentence.
- Simple explanation.
- Mistake type.
- Useful example.
- Revision action.

---

## 17. Session ending

Session ends when:

- User presses End.
- Maximum duration reached.
- User/agent permanently disconnects.
- Safety/policy ends session.
- Backend/session timeout occurs.

End flow:

1. Stop accepting new turns.
2. Cancel current generation safely.
3. Publish ending state if connection available.
4. Mark session ending/completed idempotently.
5. Final usage seconds record करें।
6. Final transcript persist करें।
7. Background report job enqueue करें।
8. Flutter result-processing screen दिखाए।
9. Report ready होने पर refresh/notification करें।

---

## 18. Session report

Report practice feedback होगा, official certification नहीं।

Possible fields:

- Session objective.
- Total speaking/practice time.
- Overall practice feedback.
- Grammar feedback.
- Vocabulary feedback.
- Fluency practice feedback.
- Selected corrected sentences.
- Useful new words.
- Strengths.
- Focus area.
- Recommended next topic.
- Rubric version.
- Prompt/model version.

Pronunciation numerical score तभी होगा जब separate acoustic evaluation validated हो। केवल transcript के आधार पर pronunciation score नहीं दिया जाएगा।

Learner report को helpful/not helpful mark कर सकेगा।

---

## 19. Progress system

- Daily practice minutes.
- Completed sessions.
- Streak.
- Topic completion.
- Repeated mistake categories.
- Vocabulary learned/revised.
- Trend by consistent rubric version.
- Recommended next activity.

Model/prompt/rubric changes से old/new scores incomparable हो सकते हैं; इसलिए version store करना mandatory है।

---

## 20. Usage limits and subscriptions

Initial beta:

- Daily minute cap.
- Per-session maximum duration.
- One active session per user.
- Maximum concurrent GPU sessions.
- Audio-only fallback availability.

Future plans may include:

- Free limited practice.
- Basic plan.
- Premium plan.
- Separate text/voice/avatar allowances.

Payments तभी add होंगे जब actual GPU cost per minute, user retention और concurrency economics measured हों। Unlimited avatar calls initial product में नहीं।

---

## 21. Admin and operations

Admin capabilities:

- Activate/deactivate topics and teachers.
- Manage topic content and learning objectives.
- View session status and failure category.
- Retry eligible report/background jobs.
- Inspect usage aggregates.
- Configure minute/session limits.
- Process export/deletion requests.
- Check consent and avatar asset status.
- View audit trail.

Admin must not expose:

- Password hashes.
- JWT/LiveKit secrets.
- Raw production secrets.
- Unrestricted user recordings.
- Sensitive transcripts without justified role/access logging.

---

## 22. Data model overview

### Accounts

- User.
- UserDevice.
- ConsentRecord.
- PrivacyRequest.

### Learning content

- AiTeacher.
- AvatarProfile.
- VoiceProfile.
- PracticeTopic.
- LessonObjective.
- VocabularyItem.

### Sessions

- PracticeSession.
- SessionTurn.
- SessionTranscript.
- SessionEvent.
- UsageRecord.

### Results

- SessionReport.
- SessionMistake.
- UserProgress.
- DailyProgress.
- ReportFeedback.

### Operations

- AuditLog.
- BackgroundJobRecord when required.
- FeatureFlag.
- Dependency/model version metadata where useful.

Binary audio/video/model files object storage में होंगे; relational metadata PostgreSQL में।

---

## 23. Data and privacy behaviour

### Default behaviour

- Raw user camera/video record नहीं होगा।
- Raw user audio record नहीं होगा।
- Final transcript और selected learning data user experience के लिए store हो सकती है according to published retention policy.
- Logs में raw content और secrets नहीं।

### Optional recording/training

Separate explicit consent required होगा। Product usage consent और model-training consent अलग होंगे। Consent withdrawal और deletion workflow documented होगा।

### Required user rights/features

- View account data.
- Correct account details.
- Delete account.
- Request data export.
- Delete eligible transcripts/recordings.
- Withdraw optional consent.
- Raise grievance/contact support.

### Avatar privacy

- Written commercial consent.
- Face/voice usage scope.
- Storage/access controls.
- Revocation/deletion terms.
- Asset hashes and consent record linkage.
- No scraped internet identities.

---

## 24. Security requirements

- HTTPS/WSS only in staging/production.
- Short-lived room-scoped LiveKit tokens.
- Backend-only LiveKit secret.
- JWT refresh rotation/revocation after compatibility tests.
- Rate limits on auth, session creation and expensive endpoints.
- Object-level authorization/IDOR tests.
- Webhook signature verification and idempotency.
- Internal-service authentication.
- Private networks/firewall where possible.
- Least-privilege database/storage accounts.
- Secret, dependency and container scanning.
- SBOM and model manifest.
- GPU/session abuse controls.
- Data breach response procedure.

---

## 25. Reliability and fallbacks

| Failure | Product behaviour |
|---|---|
| Avatar worker unavailable | Continue audio-only when possible |
| LLM timeout | Short safe fallback and retry policy |
| STT failure | Ask user to repeat; do not invent transcript |
| TTS failure | Show text/caption and controlled error |
| Network interruption | Reconnect state with timeout |
| Agent crash | Session marked failed/recoverable; no ghost state |
| RabbitMQ unavailable | Realtime call unaffected; reports retry later |
| Object storage unavailable | Defer non-realtime output; no blocking media path |
| Database failure | Reject new session safely; preserve active media behavior where possible |
| GPU capacity full | Queue/reject with clear availability message; never overcommit blindly |

---

## 26. Non-functional targets

Initial targets are engineering goals and may be revised only by benchmark evidence:

- Session start success ≥ 98% in closed beta networks.
- Crash-free sessions ≥ 98% during closed beta.
- Voice user-end-of-turn to first AI audio P95 ≤ 4 seconds on target stack.
- Realtime avatar first speaking frame P95 ≤ 5 seconds.
- Barge-in scripted success ≥ 95%.
- A/V sync approximately within ±120 ms P95 for realtime beta.
- No stale AI turn after a newer user turn.
- No cross-user transcript/audio leakage.
- 15–20 minute soak sessions without unbounded memory growth.

---

## 27. Product success metrics

- Session start success.
- Completed session rate.
- Average practice minutes.
- Repeat usage/retention.
- User-rated helpfulness of corrections.
- Voice/avatar quality rating.
- End-to-end latency.
- Crash-free sessions.
- Cost per successful minute.
- Audio-only fallback frequency.
- Report helpful/not-helpful ratio.
- Privacy/deletion request completion time.

Metrics must not require unnecessary raw recording collection।

---

## 28. Repository and change-control rules

### Phase 2 developer setup

Pinned local tool targets are Flutter 3.44.0 with Dart 3.12.0, Python 3.12.13 for backend and realtime-agent containers, and Python 3.10 for the future avatar worker. The deployment baseline is Ubuntu 24.04 LTS, Docker Engine 27+ and Docker Compose 2.29+.

On Windows, run these commands from the repository root:

```powershell
.\scripts\dev.ps1 setup
.\scripts\dev.ps1 check
.\scripts\dev.ps1 test
.\scripts\dev.ps1 up
```

`setup` creates an ignored `.env` from `.env.example`; replace every example credential before `up`. `test` runs the Python and Flutter checks. `up` starts the non-GPU PostgreSQL, RabbitMQ, LiveKit and backend-placeholder stack. Stop it with `down`.

The following command permanently removes only the Compose-managed local development volumes after validating the repository root:

```powershell
.\scripts\dev.ps1 reset
```

Docker is not installed on every Flutter workstation. In that case `check` reports the Compose verification as skipped; CI remains responsible for Compose model validation and CPU-only image build smoke tests.

### Branch model

```text
main         -> approved stable/release-ready state
development  -> active integrated development
feature/*    -> isolated feature work
fix/*        -> fixes
hotfix/*     -> urgent production fixes
```

### Documentation rule

Only these three planning documents remain authoritative:

- `README.md`
- `TECH_STACK.md`
- `DEVELOPMENT_ROADMAP.md`

Do not create duplicate architecture, roadmap, final-lock or phase-planning Markdown files. Phase progress, decisions and exit evidence may be recorded in issues, pull requests, test reports or implementation manifests without duplicating the roadmap.

### Core change rule

Changing backend, database, realtime layer, STT, LLM, TTS, avatar, broker, storage, auth design, retention policy or GPU strategy requires:

1. ADR.
2. Reason and alternatives.
3. Compatibility test.
4. Benchmark.
5. Security/privacy impact.
6. Commercial-license review.
7. Migration and rollback plan.
8. Update to the relevant authoritative document.

---

## 29. Final product principle

```text
First prove realtime transport.
Then build stable voice intelligence.
Then validate offline avatar quality.
Then add realtime avatar streaming.
Then add learning depth and product scale.
```

The product must remain useful in audio-only mode. Avatar realism is a major feature, but it must not make core English practice unreliable, unsafe or impossible to operate.
