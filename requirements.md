# **Document: Application de Formation par Scénarios (PRD)**

## **1\. Vue d’Ensemble (Overview)**

This document outlines the **Product Requirements Document (PRD)** for a Flutter-based multilingual training application. The app enables **scenario-based learning**, a proven method for effective skills training that places learners in realistic situations to practice decision-making ([Scenario-Based Training for Skill Building with Systems Training | Assima](https://assimasolutions.com/resources/blog/enhancing-skill-building-with-scenario-based-training-for-effective-systems-learning/#:~:text=Scenario,way%20in%20the%20real%20world)). The primary users are **trainers** (content creators) and **end learners** (trainees) who interact with scenario-driven training modules (scénarios). The application is a **client-only Flutter app** (no custom server), ensuring cross-platform availability (Android, iOS, etc.) and offline capabilities via local caching. All scenario content and media are stored in the user’s **Google Drive** for ease of access and sharing, using Google’s OAuth 2.0 for secure access ([Google Drive API overview  |  Google for Developers](https://developers.google.com/drive/api/guides/about-sdk#:~:text=OAuth%202,files%20inside%20the%20shared%20drive)).

Key highlights of the app include:

* **Multilingual support** with runtime language switching (French by default). The app’s interface and content can be localized to different languages without code changes ([i18n | Flutter](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#:~:text=If%20your%20app%20might%20be,Flutter%20libraries%20themselves%20are%20internationalized)). Initially, all UI labels and default scenario content will be in French (e.g., "Scénario", "Scène Suivante"), demonstrating the primary use case in French. Users can switch the UI language at runtime, and scenarios can be created in various languages (French, English, etc.). The UI language and the scenario content language are configurable separately.

* **Interactive Scenario Playback:** End users can browse a list of training scenarios and work through them scene by scene. Each **scenario** (scénario) consists of multiple **scenes** (scènes) that present a situation, and within each scene, multiple **problems** (issues or challenges) are presented for the learner to consider. Learners can view the scenario content, attempt to solve problems (mentally or in discussion), then reveal the provided resolutions. This guided interaction simulates real-world decision-making and enhances engagement and retention ([Scenario-Based Training for Skill Building with Systems Training | Assima](https://assimasolutions.com/resources/blog/enhancing-skill-building-with-scenario-based-training-for-effective-systems-learning/#:~:text=Improved%20Engagement%20and%20Retention)).

* **Content Creation & Editing (Trainer Mode):** Trainers (with a special access key) can create and edit scenarios entirely within the app. They can add scenes and problems, write descriptions and resolutions, and upload relevant images. A powerful integration with OpenAI’s GPT models allows trainers to auto-generate scenario content (or translate it) to accelerate the authoring process. Trainers can start with AI-generated text and then **edit freely**, with the AI respecting these edits in subsequent refinements (maintaining contextual chat history similar to ChatGPT’s Canvas feature).

* **Data Storage & Sync:** All scenario data is stored as JSON files on Google Drive (in a designated folder), and images are stored in subfolders on Drive. The app loads scenarios from Drive at startup (after the user connects their Google account) and caches them locally (with timestamps) for offline use. A synchronization mechanism checks the last update time to refresh content when online. This means the app can be used offline with previously loaded scenarios, and trainers’ edits are saved back to Drive for persistence.

* **Security & Privacy:** The app uses OAuth 2.0 to ensure only authorized access to the user’s Google Drive ([Google Drive API overview  |  Google for Developers](https://developers.google.com/drive/api/guides/about-sdk#:~:text=OAuth%202,files%20inside%20the%20shared%20drive)). No external server stores user data; content stays on the user’s Google Drive. A secret key is required to unlock editing features, preventing end users from modifying content. The OpenAI API key for AI features is provided by the trainer and stored securely on-device.

In summary, this PRD details a **“Scénario Formation” app**, enabling **immersive training scenarios** for learners while empowering trainers to create and manage content with ease. It covers functional requirements for both end-user and trainer experiences, data models for scenario content, UI/UX design flows, integration with Google Drive and OpenAI, settings and configuration, and the overall architecture of the solution.

## **2\. Fonctionnalités Clés (Features)**

This section describes the major features and capabilities of the application, divided into end-user features and trainer (content creator) features. It also covers internationalization and data synchronization features.

### **2.1 End User Features (Learner Mode)**

* **Scenario Selection (Liste des scénarios):** Upon launch (after initial setup), users see a **Scenario List View** displaying all available training scenarios by title (and possibly a brief description or thumbnail). Each scenario represents a training module. Users can scroll through the list and select a scenario to begin. The list is populated from scenario JSON files retrieved from the connected Google Drive folder and cached locally. (If no scenarios are available or if not yet connected to Drive, the UI will prompt the user to connect their Google Drive in settings.)

* **Scenario Playback (Parcours du scénario):** After selecting a scenario, users enter the **Scenario View**. In learner mode, this view will present one scene at a time (to focus the learner on the current situation). For the **current scene**, the app displays:

  * **Scene Title and Description:** Contextual text describing the situation. (e.g., *“Scène 1: Conflit d’équipe”* with a narrative description in the scenario’s language).

  * **Scene Image:** If an image is provided for the scene, it is shown to enhance realism (e.g., a photo of a workplace setting).

  * **Problem List:** A list of one or more problems or questions related to the scene. Each problem is typically a brief description of a challenge or decision point (e.g., *“Problème: Un membre de l’équipe conteste une décision. Que faites-vous ?”*). In the scene view, problems might be listed as clickable items (e.g., in cards or a list). The learner can click on a problem to view its details and resolution.

* **Problem Detailing (Vue du Problème):** When a learner selects a problem from the scene, the app navigates to a **Problem View**. This view shows:

  * **Problem Title & Description:** Restates the problem scenario or question in full detail (in the scenario’s language).

  * **Problem Image:** If provided, an image illustrating the problem context.

  * **Resolution/Outcome:** The recommended solution or outcome is revealed here. This text explains how an expert or the training expects the problem to be resolved. (For example, a few paragraphs discussing conflict resolution steps relevant to the problem.) By presenting the resolution after the user has considered the problem, the app facilitates a learn-by-doing approach.

  * **Return Navigation:** A button or action labeled **"Return to Scene"** (*Retour à la Scène* in French) is provided so the user can go back to the main scene view and continue with other problems or proceed forward. This ensures the user can easily navigate back after viewing the solution.

* **Scene Navigation Controls:** At the bottom of each scene page, there is a **“Next Scene”** button (*Scène Suivante* in French). After a user has reviewed all problems in the current scene, they can tap “Next Scene” to advance to the following scene in the scenario. The app then updates the Scenario View to display the next scene’s title, description, image, and associated problems. This continues until the final scene of the scenario. On the last scene, the “Next Scene” button may be replaced by a **“Finish Scenario”** or **“Return to Scenarios”** action, which when tapped will exit the scenario and return the user to the list of scenarios. Users can thus sequentially navigate through the scenario in the intended order. Additionally, a user may always use a back navigation (such as the device back or a back button in the UI) to return to the scenario list if they wish to exit early.

* **User Interface & Language:** The end-user UI is designed to be clean and intuitive, minimizing text input and focusing on reading and navigation. All UI elements (buttons, labels, instructions) appear in the user’s chosen interface language (with French as the default). The app supports **dynamic language switching** – for example, a French user interface that can be toggled to English in settings without restarting the app. Flutter’s internationalization support will be used to swap locales at runtime ([i18n | Flutter](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#:~:text=If%20your%20app%20might%20be,Flutter%20libraries%20themselves%20are%20internationalized)). The scenario content itself remains in the language it was written (each scenario JSON specifies its language). For instance, if a scenario is authored in French, all its scenes and problems will be displayed in French regardless of the UI being in English, and vice versa for an English scenario. This separation ensures multilingual content can co-exist, and trainers can prepare scenarios for different languages.

* **Offline Access (Cached Content):** End users benefit from offline reading of scenarios. Once scenarios are loaded and cached, the app can display them without an internet connection. If a user opens the app offline, the last downloaded scenario list and content will be available. They can still navigate scenarios and read content as normal. A visual indicator can show if content might be outdated (if the last sync was a while ago), prompting the user to refresh when back online. This offline capability is crucial for training in environments with limited connectivity.

* **Responsive Design:** Being a Flutter app, the UI will adapt to various screen sizes (phones, tablets). Scenarios will scroll vertically if content is long. Images will scale to fit width, etc. The design will ensure readability (short paragraphs of text as per content) and provide visual separation between scenes and problems.

### **2.2 Trainer Features (Edit Mode)**

When a trainer or content creator needs to build or modify scenarios, they can unlock **Edit Mode** using a secret key (provided by the developer/administrator). This transforms the app into an authoring tool with the following capabilities:

* **Unlocking Trainer Mode:** In the settings, a trainer enters the pre-arranged **secret key**. If the key matches the expected value, the app enables Trainer Mode features. This could be indicated by a UI change (for example, an “Edit” toggle or icon appears on scenario screens, and additional menu options become visible). The secret key acts as a simple safeguard to prevent regular users from accessing editing functions. (It is not meant as high security, but rather a convenient lock – the key might be distributed to authorized trainers only.)

* **Scenario Management (Créer/Éditer/Supprimer Scénario):** Trainers can create new scenarios, edit existing ones, or delete scenarios:

  * *Create New Scenario:* In trainer mode, the Scenario List View includes an **“Add Scenario”** button (e.g., a floating action button with a plus icon). Tapping this allows the trainer to create a blank new scenario. They will specify a scenario title (e.g., “Gestion de Conflit”), select a language for the scenario (from supported languages), and optionally a cover image or description. This action creates a new JSON file in the connected Google Drive folder (with a default structure, perhaps one empty scene) and an associated subfolder for media.

  * *Edit Scenario Metadata:* Trainers can edit a scenario’s title or language. This might be done via an “Edit Scenario” option in a scenario’s context menu. Changing the title might rename the JSON file and media folder on Drive (or update an internal name field), and changing the language sets the scenario’s default content language (used to guide AI generation and inform the UI).

  * *Delete Scenario:* A trainer can delete an entire scenario. This would remove the JSON file from the Drive folder (and possibly its media subfolder). The UI will prompt for confirmation (since deletion is irreversible). Upon deletion, the app updates the local cache to remove the scenario and it disappears from the list. (Note: appropriate caution or a backup strategy may be advised, but for this PRD we assume straightforward deletion.)

* **Scene Editing (Ajouter/Modifier/Supprimer Scène):** Within a scenario, trainers can manage scenes:

  * In the Scenario View (when trainer mode is active), each scene’s content becomes **editable**. For example, the title and description fields turn into text fields or are overlaid with an edit icon. The trainer can tap a scene title or description to edit the text inline. They can also tap the scene’s image (or placeholder) to change it.

  * An **“Add Scene”** function allows adding a new scene to the scenario. This could be a button at the end of the scene list (or in a menu) labeled "Add Scene". When adding, the app creates a new scene entry (with placeholder title like “New Scene” and empty content) that the trainer can then edit. New scenes are appended to the end of the scenario by default, and trainers can later reorder scenes if needed (reordering could be a drag-and-drop handle in edit mode or up/down arrow buttons).

  * *Reordering or Deleting Scenes:* Trainers should be able to change the sequence of scenes (since scenario flow might need adjustment). The UI could allow dragging scene cards or using an “Edit Order” mode. Deleting a scene removes it and all contained problems from the scenario JSON. A confirmation is required to prevent accidental data loss. All changes update the JSON structure accordingly.

* **Problem Editing (Ajouter/Modifier/Supprimer Problème):** For each scene, trainers can manage its list of problems (challenges/questions):

  * Problems within a scene are displayed in a list. In trainer mode, next to each problem might be edit and delete controls. Tapping a problem opens it in an editable form (similar to how an end user views it, but now with editable fields).

  * The trainer can edit the **Problem Title**, **Description**, **Image**, and **Resolution** text. All text fields support rich text or at least multi-paragraph text entry to allow detailed descriptions.

  * An **“Add Problem”** option under a scene allows the trainer to create a new problem entry. This adds a new problem object (with placeholder text) to that scene’s list which can then be edited.

  * Problems can be removed with a delete action (with confirmation). The interface ensures it’s clear which scene a problem belongs to, perhaps by keeping the scene context visible while editing a problem (like a breadcrumb “Scene 1 \> Problem A”).

* **Inline Text Editing:** All textual content in a scenario (titles, descriptions, resolutions, etc.) is directly editable in place. The UI might, for example, render text fields with a subtle background or outline when in edit mode. Trainers do not have to open separate dialogs for most edits (except maybe for larger text like the resolution which might open a bigger editor). This WYSIWYG approach makes it intuitive to quickly adjust wording. Edits are reflected immediately in the app preview so trainers see how it will appear to end users.

* **Image Upload & Management:** Trainers can add or change images for scenes and problems:

  * When in edit mode, an “Edit Image” or camera icon is shown on image placeholders. By tapping it, the trainer can choose to **upload an image** from their device (which will open the device’s image picker or camera).

  * Upon selecting an image, the app will upload it to the scenario’s Google Drive media folder via the Drive API (requires internet). The image file is ideally renamed or identified in a consistent way (e.g., scene1.jpg or a GUID). The JSON for that scene/problem will store the filename reference.

  * The app should handle resizing or compressing images if needed to optimize for web/mobile (this can be an implementation detail). Uploaded images become immediately visible in the UI for preview.

  * If offline, image upload should be deferred or disabled (with a message that internet is required to upload media). If uploading in the background, a progress indicator will inform the trainer.

  * The trainer can also remove an image (revert to none), which could delete the file from Drive or simply dissociate it (manual Drive cleanup might be needed if a lot of orphaned images accumulate, but that’s edge-case).

  * **Permissions:** Note that to access photos on the device, the app may need user permission (e.g., iOS Photo Library permission, Android storage permission). These will be requested as needed when using this feature (see Permissions section).

* **AI-Assisted Content Generation:** A standout trainer feature is integration with **OpenAI GPT models** to help generate scenario content:

  * Trainers can **auto-generate entire scenarios or specific parts of a scenario using AI.** For example, a trainer can input a high-level idea (like “customer service conflict resolution scenario, 3 scenes, intermediate difficulty”) and let the AI draft the scenes, problems, and resolutions.

  * To facilitate this, the UI provides a **“Generate with AI”** option in various contexts:

    * **Generate Full Scenario:** On the Scenario List or a new scenario screen, a trainer can choose *“Generate Scenario using AI”*. This prompts the trainer to enter or select a generation prompt. Prompts may be chosen from a **preset list** (see section 2.4 below on AI Prompt Presets) or written ad-hoc. For instance, a preset might be “Generate a scenario about *\[topic\]* with *\[N\]* scenes for *\[audience level\]*.” The trainer fills in the blanks (topic, number of scenes, etc.). When executed, the app calls the OpenAI API and obtains a suggested scenario JSON (title, scenes, problems, resolutions) in the chosen scenario language. The generated content is then loaded into the app as a new scenario (which the trainer can review and edit before saving).

    * **Generate Scene or Problem Content:** Similarly, within an existing scenario, a trainer might use AI to flesh out one part. For example, if they have written a scene description but want the AI to suggest problems and resolutions, they can use *“Generate Problems for this Scene”* which sends the scene context to OpenAI and returns some suggested problem titles and resolutions. The trainer can then tweak or accept these suggestions. Or, if a scene is empty, a *“Auto-fill Scene”* option could generate a description given just a scene title or purpose.

  * **Post-Generation Editing:** All AI-generated content appears in the app just like manually entered content, and the trainer is expected to **review and edit** it. The AI integration is meant to speed up content creation, but the trainer remains in control. Generated text can be edited inline, and images can be added or changed. This ensures the final scenario meets the trainer’s quality standards and specific context.

  * **Context Preservation:** The app should maintain context for iterative AI generations. For instance, if a trainer generates a scenario and then edits Scene 1’s description, and then requests the AI to generate Scene 2, the prompt sent to the model should include the up-to-date content of Scene 1 (including the trainer’s edits). This is akin to maintaining a **chat history or document state** for the AI, so that it doesn’t contradict or overwrite previous parts. By preserving the relevant parts of the scenario in the prompt, the AI behaves consistently and acknowledges manual changes (similar to how ChatGPT’s Canvas feature allows persistent document awareness during generation).

  * **AI Models and Options:** Initially, the app will integrate **OpenAI GPT-4.1 models** (e.g., “GPT-4.1 mini” and “GPT-4.1 nano” as hypothetical model variants for cost-efficiency). The trainer can choose which model to use (trading off speed/cost and quality – GPT-4.1 mini might be faster/cheaper but slightly less capable than nano, for example). The chosen model will be used for all generation until changed. All AI interactions require an internet connection and a valid API key (configured in Settings). If the API call fails (network issues or API errors), the app will show an error and no changes will be made.

  * **Translation via AI:** A useful feature is the ability to quickly translate scenarios to other languages. In trainer mode, a trainer can duplicate an existing scenario and have the AI translate all text. For example, if they have a French scenario and want an English version, they select *“Duplicate & Translate”*, choose the target language (English), and the app creates a copy of the scenario JSON where each textual field (title, descriptions, resolutions) is translated via the OpenAI model. The new scenario’s language code is set accordingly (e.g., “en”). Trainers should then review the translation for accuracy and cultural appropriateness. This feature leverages the model’s translation capabilities to save time, while still allowing final proofreading by a human trainer.

* **Auto-Save and Manual Save:** In edit mode, the app will attempt to **auto-save** changes to Google Drive in the background whenever content is modified. For instance, after editing a text field or adding a problem, the app can quietly push an update to the scenario’s JSON file on Drive (updating the `lastUpdated` timestamp). However, to protect against connectivity issues or conflicts, the UI will also include a **“Save”** action (e.g., a Save button or an autosave status indicator). If auto-save fails (no connection), the trainer will be alerted and can retry manually. If working offline, changes can be cached locally and the trainer can manually initiate a sync when back online. The goal is to prevent loss of work: small incremental saves keep Drive updated, but the trainer should have feedback on save success. A versioning or undo history is out of scope, but trainers could always retrieve older versions from Google Drive’s version history if needed (since Drive often keeps revisions of files).

* **Preview Mode Toggle:** Trainers might want to preview the scenario as an end-user would see it. The application can offer a **toggle between Edit mode and Preview mode**. In Preview, all editing controls disappear and the trainer can navigate the scenario just like a learner, to verify flow and content. Toggling back to Edit brings back the editing UI. This gives trainers confidence in how the content appears without needing a separate “run” environment.

* **Multi-Platform Editing:** Because the app is in Flutter, trainers could even use it on a desktop (if compiled for web or desktop) for easier typing, or on a tablet for more screen space. All editing features are designed to be usable on mobile, but also benefit from larger screens.

### **2.3 Internationalization & Localization (Multilingual Support)**

* **App Interface Language:** The app supports **multiple UI languages**, and can switch between them at runtime based on user preference. At launch, the default interface language will be French (since the initial target user base is French-speaking trainers/learners). All static text in the app (button labels, menu items, prompts, messages) will be translated into the supported languages (starting with French, and English as a second language; more can be added via Flutter’s localization mechanism). Users can change the app’s language in the Settings, which will immediately update the visible text via Flutter’s locale change (using `MaterialApp.locale` or similar). This is facilitated by Flutter’s internationalization libraries ([Flutter: Internationalization & Switching Locales Manually | by Puneet Sethi | Medium](https://medium.com/@puneetsethi25/flutter-internationalization-switching-locales-manually-f182ec9b8ff0#:~:text=At%20times%20you%20will%20have,at%20the%20Dart%20intl%20tools)) ([i18n | Flutter](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#:~:text=If%20your%20app%20might%20be,Flutter%20libraries%20themselves%20are%20internationalized)).

* **Scenario Content Language:** Each scenario JSON file carries a `language` field (e.g., “fr” for French, “en” for English). This denotes the language of the content within that scenario. The app will render the scenario exactly as authored, without translation, to preserve the fidelity of the training material. If a trainer wants the same scenario in another language, they should use the duplication/translation feature rather than expecting the app to translate on the fly. This design ensures the training content remains as intended by its author and avoids automatic translation errors during a session.

* **AI Output Language:** When using AI generation features, the output is tailored to the scenario’s language. The app will include instructions in prompts to the AI to respond in the scenario’s language. For example, if `language` is "fr", the prompt will say (in French or with an instruction) that all generated content should be in French. This ensures consistency and that trainers don’t receive content in the wrong language by accident. If translating a scenario via AI, the target language is specified accordingly.

* **Numbers, Dates, and Formats:** If any date or number formatting is used in content or UI (e.g., a timestamp or “Last updated” label), the app will localize these formats according to the current UI locale (using the intl package for formatting). However, in training content, it’s expected that dates/numbers are part of the scenario text if needed, and thus written by the author in the appropriate format for that language.

* **French Terminology in App Logic:** As the initial implementation is French-first, internal references and default naming follow French conventions. For instance, internally the “scenes” may be referred to as “scènes” in comments or default JSON templates. Any example scenarios provided with the app will be in French to showcase the primary use-case (e.g., a sample scenario might be "Exemple: Formation en Service Client"). This focus ensures that the first user experience is fully French. Subsequent language support will be added by providing translated strings and ensuring the UI layout can accommodate different text lengths.

* **Right-to-Left (RTL) Support:** While not explicitly requested, a note for completeness: if languages like Arabic or Hebrew are to be supported in the future, Flutter’s localization would handle text direction. The design should be tested for RTL flipping (e.g., alignment and order of elements). For now, we assume only LTR languages like French/English.

### **2.4 Data Synchronization & Caching**

* **Google Drive Integration (Sync as Storage):** The app uses Google Drive as its cloud storage backend for scenario files and media. This makes the content easily accessible and shareable for trainers (since they can even edit JSON files directly in Drive in a pinch, or upload images outside the app). The integration leverages the Google Drive REST API via an OAuth 2.0 authenticated session ([Google Drive API overview  |  Google for Developers](https://developers.google.com/drive/api/guides/about-sdk#:~:text=OAuth%202,files%20inside%20the%20shared%20drive)). Essentially, the **Flutter app is a Google Drive client** ([Google Drive API overview  |  Google for Developers](https://developers.google.com/drive/api/guides/about-sdk#:~:text=The%20Google%20Drive%20API%20lets,application%20using%20the%20Drive%20API)) dedicated to a specific folder containing training content.

* **Initial Drive Setup:** In the app settings, the user (trainer or end user) must **connect a Google Drive folder**. This triggers Google’s OAuth flow (likely through a plugin or webview). The user grants permission for the app to view and manage files in their Google Drive (the scope could be limited to specific files or a folder). After authentication, the user is prompted to either select an existing Drive folder or create a new one to serve as the “Training Scenarios” folder. The app stores the ID of this folder for subsequent API calls. Only files within this folder (and its subfolders) will be accessed by the app. This compartmentalization limits the app’s scope on Drive and keeps personal files separate.

* **Loading Scenarios from Drive:** On app startup (or whenever the user hits “Refresh”), the app fetches the list of scenario JSON files from the designated Drive folder. For each file:

  * It checks if the file is already cached locally. If not cached, it will download the file content.

  * If cached, it compares the `lastUpdated` timestamp (from the JSON content or the Drive file’s modified time) with the locally stored timestamp. If the Drive version is newer, it will download the latest content and update the cache.

  * Downloaded JSON files are parsed into the app’s data model (list of Scenario objects in memory). Similarly, for images referenced in the scenarios:

    * The app may pre-download all images referenced by the scenarios for offline use. This could be done lazily (download when needed/displayed) or eagerly (download all at sync time). A balanced approach is to download each image the first time its scene is viewed, and then cache it. A full pre-fetch might be offered via a “Download All Media” option if needed.

    * Images downloaded are stored in the app’s local file storage (e.g., using `path_provider` to get app directory). They can be saved with names like `scenarioTitle_imageName.jpg` or by Drive file ID.

* **Local Cache Storage:** The app will maintain a local SQLite database or simple file-based cache to store:

  * Scenario JSON content (perhaps as .json files in app directory or as objects in a small database).

  * Image files (in an images folder in app data).

  * Metadata like last sync time, and the Drive file IDs and their last known modified timestamp.

  * These are used for offline access and quick loading. Local data should be updated atomically to avoid partial writes (e.g., write to temp then replace, or use a transaction in DB).

* **Timestamp Validation:** The `lastUpdated` field in each scenario JSON serves as a quick check and also can be shown in the UI (e.g., “Last updated: 2025-04-10”). The app will trust the Drive file’s modified time as primary source of truth for syncing (since if someone edits the JSON via Google Drive web, they might not change the internal `lastUpdated` field). However, when the app itself edits a scenario, it will update this field and save, thus Drive’s modified timestamp and the field should be in sync. We might use both: if either timestamp indicates newer content, update the cache.

* **Manual Refresh:** A **“Refresh”** button (e.g., on the scenario list or in a pull-to-refresh gesture) allows the user to manually trigger a resync with Google Drive. This re-fetches file list and updates any changed scenarios. It’s useful if multiple trainers share a Drive folder or if an update was made externally.

* **Conflict Handling:** In the simple case, one trainer is editing at a time. If multiple trainers could edit (by sharing the folder and secret key), conflicts might occur. This PRD does not deeply cover multi-user editing conflict resolution. As a basic measure, if the app finds a scenario file on Drive that has a newer timestamp than the local cache and the trainer is currently editing that scenario, it can warn the trainer of an external update. Perhaps lock the scenario from simultaneous edits or require the trainer to refresh first. For now, we assume single-editor or coordinated use.

* **Data Consistency:** When trainers save edits, the app writes the JSON back to Drive via the API (HTTP PUT/PATCH). If offline, it queues the save and marks the scenario as “Pending Sync”. Once connectivity is restored, it will try again. The UI should indicate if some changes are not yet saved to cloud (to avoid confusion). In the worst case, if a user’s device fails before saving, they might lose unsynced changes, so we encourage frequent connectivity when editing or careful manual save.

* **Drive File Structure:** Each scenario is stored as an individual JSON file in the chosen Drive folder. Additionally, for organizational clarity, **each scenario has a subfolder (within the main folder) for its media**. For example, for a scenario titled "TeamConflict", we might have:

  * `TeamConflict.json` (the scenario file)

  * A folder `TeamConflict_media/` containing `scene1.jpg`, `problem2.png`, etc., used by that scenario. The JSON references images by filename (or path). The app knows to look in the corresponding media folder for those files. Alternatively, the images could be in the same folder with unique names, but separating into subfolder keeps things tidy. The PRD assumes the subfolder approach.

  * The app will ensure to create the subfolder when a new scenario is made, and set the correct permissions (though if the parent folder is user-owned, it inherits that). When uploading images, it targets the correct subfolder.

  * If the scenario title changes, ideally the folder name should change to match. However, renaming folders on Drive can be done via API. The app may choose to keep an internal immutable scenario ID to avoid renaming complexities, but since not specified, using title as folder name is acceptable with caution (ensuring to rename the folder when title changes, and updating references).

* **Use of Drive API:** The integration will use Google’s official APIs. Flutter can use packages like `google_sign_in` for OAuth and then `googleapis` for Drive operations ([How to Integrate Google Drive APIs & Use Google Drive as Storage Bucket for flutter Application? | by Arsalan umar | Medium](https://arxlan40.medium.com/how-to-integrate-google-drive-apis-use-google-drive-as-storage-bucket-for-flutter-application-2c1daabd47d1#:~:text=cupertino_icons%3A%20,1.3.8)). The Drive API allows listing files, downloading and uploading file content, and managing folders ([Google Drive API overview  |  Google for Developers](https://developers.google.com/drive/api/guides/about-sdk#:~:text=You%20can%20use%20the%20Drive,API%20to)). The app will leverage these:

  * Query the folder for files with mimeType application/json (for scenarios).

  * Download file content which comes as JSON text.

  * Upload (update) file content by file ID when saving.

  * Create new files/folders for new scenarios or images (image files might use MIME type image/jpeg etc., and the folder’s ID as parent).

  * The app will handle the necessary authentication headers (likely using an auth client that injects the OAuth token ([How to Integrate Google Drive APIs & Use Google Drive as Storage Bucket for flutter Application? | by Arsalan umar | Medium](https://arxlan40.medium.com/how-to-integrate-google-drive-apis-use-google-drive-as-storage-bucket-for-flutter-application-2c1daabd47d1#:~:text=class%20GoogleHttpClient%20extends%20IOClient%20,String%2C%20String%3E%20headers%7D%29))).

* **Performance Considerations:** Scenarios JSON files are expected to be reasonably small (likely \< 1MB each, as they are mostly text). Loading even dozens of scenarios is quick. Images will dominate bandwidth; caching them prevents re-downloading every time. We will implement lazy loading for images to avoid long startup times if the user has many scenarios with many images. Also, using thumbnails could be considered (Drive API can provide thumbnail links for images), but it might complicate offline use, so probably we download the actual images once.

* **Scalability:** A typical trainer might have a few to maybe dozens of scenarios. The design should handle dozens of JSON files without problem. If the list grows large, we could implement search or categorization in the future (not in scope now). The main folder could also have subfolders by category, but for now we assume a flat list of scenarios in one folder.

* **Security and Access Control:** The content is on the user’s Drive, meaning it inherits Google’s security (the user can share the folder with other trainers if collaborative editing is desired, or with learners if they want learners to have direct access to JSON, though the latter is not needed because learners use the app). The app itself only accesses files in that specific folder (thanks to using the folder’s ID in queries). OAuth tokens are stored securely (likely in flutter\_secure\_storage) and refreshed as needed. The secret key for trainer mode is a simple client-side check and does not grant additional Drive permissions – it only unlocks UI features.

## **3\. Modèle de Données (Data Models)**

The core data structure for the training content is a **Scenario JSON schema**. Each scenario is represented as a JSON object with the following structure:

{  
  "title": "string",            // Title of the scenario (e.g., "Gestion de Conflit d'Équipe")  
  "language": "fr",            // Language code of the scenario content ("fr", "en", etc.)  
  "lastUpdated": "ISODateTime", // Last update timestamp, e.g., "2025-04-15T10:00:00Z"  
  "scenes": \[  
    {  
      "title": "string",        // Title of the scene (e.g., "Scène 1 : Contexte")  
      "description": "string",  // Descriptive text setting the scene  
      "image": "image\_filename.jpg", // Filename of an image for this scene (stored in media folder)  
      "problems": \[  
        {  
          "title": "string",       // Title of the problem/question  
          "description": "string", // Full description of the problem situation or question  
          "image": "image\_filename.jpg", // Filename of image illustrating the problem (optional)  
          "resolution": "string"   // Text of the resolution or answer to the problem  
        }  
        // ... more problems  
      \]  
    }  
    // ... more scenes  
  \]  
}

**Explanation of Data Fields:**

* **Scenario Level:**

  * `title`: The scenario’s name. This is shown in the scenario list. It should be concise but descriptive (users might see just this title when browsing scenarios).

  * `language`: A code indicating the language of all text in this scenario. For example, `"fr"` for French, `"en"` for English, `"es"` for Spanish, etc. This guides the app’s handling (ensuring AI generation uses the correct language and possibly filtering scenarios by language in the UI if needed). The app may restrict this to supported languages only.

  * `lastUpdated`: An ISO 8601 timestamp (UTC) marking when the scenario was last modified. The app updates this whenever a trainer saves changes. It can be used to show a “last updated” note to trainers and is used for cache validation (as described earlier). Format example: `"2025-04-15T08:30:00Z"`.

  * `scenes`: An **array of scene objects**. Order in the array is the intended chronological order of the scenario.

* **Scene Level (scenes\[\]):**

  * `title`: The title or heading of the scene. This could be a short name or summary (e.g., "Introduction", "Scene 2: Escalation"). In French scenarios, might be "Scène 2 : Escalade du conflit".

  * `description`: The narrative description setting up the scene. This is typically a few sentences or paragraphs describing the situation that the learner is in during this scene. It provides context needed to understand the forthcoming problems. (For instance, describing the environment, the mood, the key challenge of that scene.)

  * `image`: The filename of an image illustrating the scene (if any). This image file is expected to reside in a Drive subfolder for this scenario. Example: `"scene1.jpg"`. If no image is available, this field could be an empty string or omitted, and the app will simply not show an image container.

  * `problems`: An array of **problem objects** associated with this scene. Each represents a question or challenge the learner must think about.

* **Problem Level (problems\[\]):**

  * `title`: A short title or identifier for the problem. It could be a question or a label like “Problem 1” or a brief summary (e.g., "Team Member Dispute"). This might be shown in the list of problems on the scene view.

  * `description`: A detailed description of the problem scenario. This text lays out the challenge or question in detail, potentially including dialogue or specifics. For example: *“Un membre de l’équipe remet en cause une décision que vous avez prise en tant que chef d’équipe. Il semble contrarié devant les autres. Que faites-vous ?”* (This would be a French description of a problem scenario.)

  * `image`: Filename of an image specific to this problem (optional). For instance, a photo of a confrontational meeting. If provided, it aids visualization. If not, the scene image might suffice or no image is shown on the problem view aside from the scene image context.

  * `resolution`: The explanation or solution to this problem. This text is what the trainer wants the learner to learn as the correct approach or outcome. It might be structured as advice, an example of best practice, or consequences of certain actions. For example: *“En tant que chef d’équipe, il est important d’écouter les préoccupations... \[etc\]. Dans ce cas, une approche possible serait de…”* and so on. This is displayed after the user has had a chance to consider the problem.

**Storage Format and Editing:**

* The JSON is stored as a text file (`.json`) on Google Drive. The structure is human-readable and editable, which means advanced trainers or developers could manually edit it outside the app if necessary (though the preferred way is via the app).

* The app will parse this JSON into internal model classes (e.g., Scenario, Scene, Problem classes in Dart) for runtime use. It will also serialize changes back to JSON when saving.

* We expect the JSON to be UTF-8 encoded to properly handle accented characters and non-Latin scripts for different languages.

* The schema is flexible to extension: future fields (like difficulty level, estimated duration, tags, etc.) could be added at either the scenario or scene/problem level without breaking the app (the app can ignore unknown fields).

**Data Relationships and IDs:**

* There are implicit relationships: each scene’s position in the array is its sequence order. We might not use explicit IDs for scenes or problems in the JSON (to keep it simple), but internally the app could assign IDs if needed for state management. The `title` can serve as a key in many cases (though titles might not be unique across scenes or problems, so an index might be used).

* The link between scenario JSON and image files is by name and folder convention as discussed. The JSON does not store full paths or Drive file IDs to remain storage-agnostic. The app can map `scenario title + image filename` to a Drive file path or ID behind the scenes.

**Example (Pseudo-Content):**

To illustrate, a small example in French:

{  
  "title": "Gestion de Conflit d'Équipe",  
  "language": "fr",  
  "lastUpdated": "2025-04-15T09:00:00Z",  
  "scenes": \[  
    {  
      "title": "Scène 1 : Tension Monte",  
      "description": "Vous êtes le manager d'une petite équipe. Deux de vos collègues commencent à se disputer ouvertement lors d'une réunion...",  
      "image": "scene1.jpg",  
      "problems": \[  
        {  
          "title": "Intervenir ou Observer ?",  
          "description": "Un conflit éclate entre Jean et Marie. Ils échangent des paroles dures devant tout le monde. Allez-vous intervenir immédiatement ou les laisser s'exprimer d'abord ?",  
          "image": "",  
          "resolution": "Il est conseillé d'intervenir calmement pour apaiser les esprits. Par exemple, remerciez-les d’exprimer leurs points de vue et proposez de discuter du problème en privé après la réunion pour ne pas gêner les autres participants..."  
        }  
      \]  
    },  
    {  
      "title": "Scène 2 : Discussion Privée",  
      "description": "Après la réunion, vous invitez Jean et Marie à discuter en privé du conflit...",  
      "image": "scene2.jpg",  
      "problems": \[ ... \]  
    }  
  \]  
}

This example shows how content might look in JSON. The app would render this to the user as two scenes with their respective problem. It demonstrates using French content (matching the language code).

**Media Storage Details:**

* As mentioned, images like `"scene1.jpg"` are expected to be located in a Google Drive folder dedicated to this scenario. For the above scenario "Gestion de Conflit d'Équipe", if that is also the filename (`GestionDeConflitdEquipe.json` perhaps), the images would be in a folder e.g. `GestionDeConflitdEquipe_media/scene1.jpg`.

* The JSON only keeps the filename, not the full URL, to keep it portable. The app will know the mapping of scenario to its media folder (perhaps by naming convention or by storing a mapping in a separate config file if necessary).

The data model is kept intentionally simple (just nested arrays and fields) to ease manual editing and debugging. It also fits well with how content is structured logically (scenarios contain scenes, scenes contain problems). This hierarchical JSON structure can be easily extended or consumed by other tools if needed.

## **4\. Parcours Utilisateur (UI/UX Flows)**

In this section, we describe the user experience flows for both end users (learners) and trainers (authors). This includes screen-by-screen descriptions and how users navigate through the app’s functions. We will cover the initial setup, scenario browsing and playback (learner flow), and scenario creation/editing (trainer flow), as well as the settings flows for configuration.

### **4.1 Initial Setup Flow**

* **App Launch (First Time):** When the user opens the app for the first time, they will be greeted with an onboarding or setup screen. Since the app’s content is stored on Google Drive, the primary setup step is to **connect to Google Drive**. The user is prompted with a message explaining that the app needs access to a Google Drive folder to store training scenarios. A **“Connect Google Drive”** button initiates the OAuth login.

  * The user signs into their Google account (if not already) and grants permission. (The OAuth screen will list what access is being granted, ideally “See and manage files in your Training Scenarios folder on Google Drive”).

  * Upon success, the app either asks the user to **select a folder** or auto-creates a default folder (e.g., “TrainingScenarios”) in the user’s Drive. Selecting a folder might be done via a folder picker API or by listing the user’s Drive structure (which is more complex). A simpler approach: auto-create “TrainingScenarios” if not present, and store its ID. Advanced: allow the user to change it later in settings.

  * Once the folder is set, the app fetches scenario files. If none exist (brand new user), the Scenario List will be empty (possibly with a friendly message “No scenarios yet. If you are a trainer, create one via the edit mode. If you are a learner, please wait for scenarios to be added.”).

* **Role Determination:** The app doesn’t have separate roles at login (there’s no separate trainer login); instead, any user can potentially become a trainer by entering the secret key. So initially, the app treats the user as an end user (learner) by default. There might be a subtle note in the Settings icon or somewhere that says “Trainers: enter code to edit scenarios” to inform about the existence of trainer mode.

* **Main Screen after Setup:** Typically, after connecting Drive, the main content screen is the **Scenario List View** (or a dashboard if one were designed, but list is primary). The app UI layout likely has:

  * A top app bar with the app name (e.g., “Scenario Training” or localized “Formation Scénarios”) and perhaps a Settings icon.

  * The list of scenarios (could be a ListView of cards or ListTiles).

  * If in trainer mode (after unlocked), the list might also show an “Add” button.

  * If no scenarios exist, an illustration and text might encourage creating one (in trainer mode) or inform to connect a different folder or wait (if not trainer).

### **4.2 End User Scenario Flow**

This describes how a learner interacts with the scenarios:

1. **Scenario List View:** The user sees all available scenarios, each listed with its title (and potentially an icon or thumbnail).

   * If a scenario’s first scene has an image, the app might show a small thumbnail next to the title for visual interest.

   * It might also show a language label if multiple languages are present (e.g., a flag icon or “\[FR\]”).

   * The list is scrollable. Tapping on a scenario entry opens that scenario.

2. **Open Scenario (Start):** When a scenario is selected, the app navigates to the **Scenario View** for that scenario. By default, it will display the first scene.

   * **Scene View Layout (Learner mode):** At the top, the scene title is shown (perhaps with a scene number if desired: “Scene 1: ”). Below that, the scene description text. If an image exists, it is displayed prominently (e.g., full width image below the title, with description text below the image, or vice versa).

   * Following the description, a heading like "Problems:" might precede the list of problems, or the problems might simply be listed with some visual distinction (like cards).

   * Each problem is typically shown by its title in a clickable format (like a button or expandable panel). The user can click to reveal details.

3. **Viewing a Problem:** Suppose the user clicks on Problem 1 in Scene 1\. The app transitions to **Problem View**:

   * This could be a new page/screen that slides in (with its own route), showing the problem title and full description, any image, and the resolution text. In effect, it’s a detail page.

   * Alternatively, the UI could use an accordion or expansion panel on the same page to reveal the resolution below the problem title. However, a separate page is cleaner for focus and matches the requirement of a "Return to Scene" action.

   * The Problem View likely has the app bar title set to the problem title or something like “Solution”. It displays the content and at bottom has a **Return** button.

   * The user reads the resolution. Once done, they tap "Return to Scene" which closes this detail and brings them back to the Scene View (which still shows the list of problems).

4. **Proceed to Next Problem or Scene:** Back on the Scene View, the user can click other problems in any order. They might also ignore some and click "Next Scene".

   * The app should not force the user to view all problems before moving on (flexibility in adult learning). But it might mark which ones have been viewed (for example, change the color of visited problem links).

   * After finishing with Scene 1, the user taps **Next Scene**. The UI then updates to Scene 2’s content:

     * Possibly via a page transition (sliding to a new Scene page for Scene 2).

     * Or the app could keep the same view and just update the content (with an animation). But likely each scene is a separate page in a PageView or navigation stack.

5. **Completing a Scenario:** When the user is on the final scene, the UI would show a **Finish** button instead of Next (or Next is disabled if it would go beyond last scene). On tapping finish (or the back button), the app returns to the Scenario List.

   * Optionally, we could show a completion message like “Scenario Completed\!” or even track completion status (but that’s beyond current scope).

   * The scenario could be marked as completed in the UI (e.g., a checkmark on the list entry) if we want to enhance the experience.

6. **Exiting Mid-Scenario:** If the user goes back early (using the Android system back, or an in-app back arrow), the app should confirm if progress needs to be saved (in our case, there's no input from the user to save, so just going back is fine). They can resume anytime by selecting the scenario again (which will start at the beginning unless we track scene progress in future).

7. **Switching UI Language:** At any point, the user can go to Settings and change the app language. This is typically not frequently done, but if changed, the app might refresh the UI strings immediately. For example, if the user switches from French to English UI, the app bar now says “Scenario List” instead of “Liste des Scénarios”, etc. The content of scenarios (French scenario content) remains in French. This allows bilingual users to use an English interface to read French scenarios, if desired.

8. **No Scenario Content (Learner case):** If a learner somehow has the app but no scenarios have been created in the connected folder, the scenario list will be empty. The app might periodically check for new content (or rely on manual refresh). Possibly, if the user is truly just a learner, they might get the content by the trainer sharing that Google Drive folder with them and they connect to it. Alternatively, a trainer could pre-load content on a device. In any case, the learner’s main flow is consuming scenarios as above.

### **4.3 Trainer Editing Flow**

This flow covers how a trainer would perform content creation and editing tasks in the app:

1. **Accessing Trainer Mode:** The trainer (who knows the secret key) opens the app. If it’s the first time, they do the Drive setup as well. They then go to **Settings** (usually accessed via a gear icon on the main scenario list screen).

   * In Settings, an input field or a dialog asks for the **Trainer Secret Key** (some code or password given out-of-band). The trainer enters it and confirms.

   * If correct, the app enables trainer features. This might immediately toggle the app into an “editing enabled” state. Possibly the UI could now show an edit icon on the scenario list or change color to indicate trainer mode.

2. **Creating a New Scenario:** From the Scenario List, the trainer taps the **Add (+)** button:

   * A dialog or new screen asks for basic info: Scenario Title, Language. Possibly an option to auto-generate content or start blank.

   * The trainer inputs a title (e.g., “New Scenario about X”). They pick a language from a dropdown (say, French).

   * If they want to initialize with AI, there could be an option here like “Generate content for me”. If so, upon confirming, the app will call the AI to generate a starter scenario (maybe asking for some keywords or using a default prompt).

   * If not using AI, it creates a scenario JSON with one empty scene (or no scenes, though having at least one helps structure).

   * The app then opens the new scenario in the Scenario View, now in edit mode, ready for the trainer to fill in details.

3. **Editing Scenario Info:** In the new scenario (or an existing one), if the trainer wants to rename it or change language:

   * They might click an “Edit” icon next to the scenario title (maybe at the top of the scenario view). This could open an edit field or a modal where they change the title text and/or language dropdown. On save, the app updates the JSON and (if needed) renames the Drive file and media folder. The UI reflects the new title.

   * Changing language in an existing scenario might be rare (they’d likely create in the correct language to start), but the option is there if needed. If changed, it mainly affects how the AI generation works going forward, since existing content won’t auto-translate.

4. **Adding Scenes:** In the scenario editor view, the trainer wants multiple scenes:

   * They tap **“Add Scene”** (could be a button at bottom of current scenes list or in an overflow menu). Immediately, a new scene entry appears. Possibly it navigates into a scene detail editor.

   * The new scene might open in an editor where the trainer can set the scene title and description. If not auto-navigating, the app might create a blank scene card on the scenario view which the trainer then selects to edit in detail.

   * Many design options: A straightforward one is to navigate to a Scene Edit page.

5. **Scene Edit Page:** This page shows fields for the scene:

   * Title (text field), Description (multi-line text area), an Image section (with an “Add Image” button).

   * Below that, a list of problems (initially empty for a new scene).

   * There is an option to **Add Problem** on this page.

   * The trainer fills in the title and description. If they have an image ready, they tap Add Image, choose from gallery or camera, then confirm upload. The image appears in the UI.

   * They then tap Add Problem to create the first problem.

6. **Adding/Editing a Problem:** After tapping Add Problem:

   * Possibly the UI opens a **Problem Edit dialog** or navigates to a Problem Edit page. Alternatively, the scene edit page could expand to show editable fields for the new problem.

   * In any case, fields for Problem Title, Description, Resolution (and image) are available to input.

   * The trainer writes a problem, possibly something like a question, and then the resolution which is the answer.

   * They can add an image similarly if desired.

   * After entering details, they save the problem. The UI returns to scene view (which now lists that problem).

   * The trainer can repeat to add more problems to the scene. Each saved problem could be listed perhaps with just its title as a summary on the scene page (with maybe an edit icon to edit again or tap to open).

   * The trainer can also edit or delete a problem by selecting it from the list (which goes back into the edit mode for that problem’s fields or an option to delete).

7. **Return to Scenario Overview:** Once done with that scene, the trainer can navigate back to the scenario overview which lists all scenes. Now they will see Scene 1 with its title, maybe a snippet of description, and possibly the first problem’s title as a summary. They can then add another scene via Add Scene and continue the process.

   * In some designs, the scenario view might allow inline editing of scenes without separate pages (for example, expanding each scene card to show its fields). But often a separate page or dialog for editing each scene is cleaner to implement.

8. **Reordering Scenes:** Suppose the trainer realizes Scene 2 should actually come before Scene 1\. They can reorder:

   * Perhaps on the scenario overview, there’s a “Reorder Scenes” mode or simply drag-and-drop. The trainer drags Scene 2 above Scene 1\. The app updates the ordering in the JSON.

   * The numbering or titles might be automatically updated if they included numbers (if the titles were manual like "Scène 1", trainer might need to rename it; or we could just not include explicit numbers in titles to avoid confusion, relying on position).

   * Similarly, if needed, problems could be reordered within a scene (drag their order).

9. **Using AI to Generate Content:** At any point in editing, the trainer can invoke AI generation:

   * If on a blank new scenario, they might choose a “Generate Full Scenario” option from a menu. This might prompt: “Enter a topic or goal for the scenario” or “Select a prompt preset”. For example, the trainer picks a preset prompt like "Customer Service Training (5 scenes)" and enters a couple keywords (like difficult customer, phone support). They hit generate. A loading indicator shows progress (maybe with a fun AI icon).

   * After a few seconds, the AI returns a draft scenario. The app parses it and populates the scenario. The trainer is then shown the generated content, perhaps with a summary “5 scenes generated”. They can navigate through and edit as needed. The AI generation might automatically save the scenario to Drive as well (to ensure no loss).

   * If generating just part of a scenario: say they have a scene set up but want the AI to suggest problems. They click “AI \-\> Generate Problems for this Scene”. They might be asked how many problems or just let AI decide. The AI receives context (the scene description) and returns some problems and resolutions. The app creates those problem entries for the trainer. The trainer reviews and possibly edits them for accuracy or tone.

   * Another usage: If the trainer wrote a problem description but is unsure of a resolution, they could hit a “Generate Resolution” button on the problem edit, which uses OpenAI to propose a resolution text.

   * The UI should mark AI-generated text in some subtle way (maybe italic or a small "AI" tag) until the trainer edits it, so they remember to review it carefully.

10. **Duplicating and Translating a Scenario:** If a trainer wants to translate:

    * On the scenario list, they pick an existing scenario (e.g., French one), select *“Duplicate & Translate”* from an options menu.

    * The app asks which language to translate into (list of supported, say English). The trainer selects English.

    * The app creates a copy of the JSON structure (all scenes/problems same, but text content will be translated by AI).

    * It sends each text field through OpenAI (or all together if prompt can handle structured translation). This might be done scene by scene to manage token limits.

    * After a moment, a new scenario appears in the list, titled maybe "Gestion de Conflit d'Équipe (EN)" or just the same title but language now en, and content now in English. The trainer can open it and verify the translation, adjust phrasing, etc.

    * Images are reused since visuals are language-agnostic. So the media folder could be duplicated or perhaps both scenarios point to the same images (to avoid duplicating files, one could reuse, but then cross-scenario references on Drive might be messy. Safer to copy the images to a new folder if we truly duplicate scenario. This doubles storage but ensures each scenario folder is self-contained).

    * Now the trainer has two versions of the scenario to distribute to different language audiences.

11. **Saving Work:** Throughout editing, the trainer might notice small “Saving...” messages or icons indicating the content is being saved to Drive. If there's a Save button (like in a toolbar), they tap it to ensure everything is saved. The app confirms save success (maybe a brief toast “Saved to Drive at 10:30am”).

    * If offline or save fails, an error icon might appear. The trainer can retry when online.

    * The trainer should occasionally go back to scenario list and use Refresh to ensure their changes appear (though if they just made them, they will).

    * All edits the trainer does reflect immediately in their local model; saving is more about persistence to cloud and for other devices.

12. **Exiting Trainer Mode:** If the trainer is done editing and wants to use the app as a learner (or hand the device to someone else), they can toggle off trainer mode. Perhaps a “Lock Trainer Mode” or simply by restarting the app (which by default won’t be in trainer mode until key is entered again, unless we allow storing the fact they unlocked it).

    * For security, probably the app does not remember the secret key indefinitely (or maybe it does per device?). This can be decided: if the trainer is always the one using the device, remembering it is fine. If the device may be shared, better to lock it each time.

    * Assume a simple approach: the app stays in trainer mode until manually locked or app is restarted; a setting to “Lock trainer features” will hide editing UI again (maybe requiring re-entry of key to unlock next time).

13. **Multi-trainer Collaboration:** Not directly in the flow, but if two trainers share the Google Drive folder, one could edit on their device and another on theirs. They both have to have the secret key. They would each see updates via the refresh mechanism. They should coordinate to not edit the same scenario at the same time (since last save wins). This use-case would be documented to trainers if needed but not enforced by the app beyond timestamp checks.

### **4.4 Settings & Configuration Flow**

The settings screens allow the user (either role) to configure the app’s connections and preferences:

* **Accessing Settings:** Usually via a gear icon in the top bar or a drawer. Clicking it opens the Settings page.

* **User Settings (General):** These settings are available to all users:

  * **Google Drive Folder:** Displays the currently linked folder name/path. There is an option to **Change Drive Folder** or **Re-link Account**. Tapping it initiates the Google picker or a re-auth flow so the user can select a different Google account or folder. (This is useful if the user initially linked the wrong account or if a learner needs to point to a trainer’s shared folder.)

  * Possibly show the user’s Google account email that is connected, and an option to sign out from it (which would clear local tokens and require re-auth).

  * **Language (Langue de l’interface):** A dropdown or list to pick the UI language (e.g., Français, English). Changing this immediately applies as described. This might be labeled “App Language” to clarify it’s the interface, not scenario content language.

  * **About/Help:** Info about the app version, developer, maybe a link to documentation. (This is standard but not key to functionality.)

* **Trainer-Specific Settings:** These are visible only after entering the secret key (or on the same settings page but greyed out until unlocked):

  * **Enter Trainer Key:** If trainer mode is not active, a field or button here says “Trainer Access: \[ Enter Key \]”. Once correctly entered, this section unlocks and possibly the field is replaced with a label “Trainer mode enabled”.

  * **OpenAI API Key:** A secure text field where the trainer can input their OpenAI API key. The app will store this (preferably encrypted on device). The field should hide the key (like a password) or at least not display it plainly after entry. Possibly show a portion and an edit button to change it. The trainer must obtain this key from OpenAI’s dashboard. Instructions might be provided (“Get API key from OpenAI website”).

  * **Select AI Model:** An option to choose which model to use for generation. Could be a dropdown listing available models (e.g., “GPT-4.1-mini (fast)” vs “GPT-4.1-nano (accurate)”). This populates the model parameter for API calls. If the OpenAI API key doesn’t have access to a certain model, the app should handle errors if selected. By default, one is selected (perhaps the smaller one for cost).

  * **Manage Prompt Presets:** A subsection where the trainer can define and edit the templates used for AI generation prompts. It might have a list of presets, each with a name and prompt text. For example:

    * Name: “Conflict Resolution Scenario”, Prompt: *“Génère un scénario d’apprentissage en **{language}** sur le thème **{topic}**, comprenant **{numScenes}** scènes avec des problèmes et résolutions détaillés. Le public cible est **{audience}**.”*

    * The curly brace parts indicate placeholders the app might ask the trainer to fill when using the preset.

    * The trainer can create new presets by providing similar template text, possibly with placeholder notation, or just a full prompt where they’ll edit it at use time.

    * The UI for this could be a list with an “Add Preset” function and edit/delete for each. Presets are stored locally (perhaps in a small JSON or in app preferences). They are not stored on Drive, assuming they are more personal preference. (Alternatively, storing them on Drive could allow them to roam with the user’s content, but not necessary.)

  * **Reset Data / Clear Cache:** Possibly a troubleshooting option to clear the local cache of scenarios (forcing a full refresh from Drive). This can be helpful if something got corrupted or if the user wants to free space. This would not delete Drive data, just local.

  * **Exit Trainer Mode:** A button to lock the trainer features (could simply say “Lock Trainer Mode” or if we want them to re-enter key next time, that’s implicit on app restart anyway).

* **Saving Settings:** Most settings take effect immediately (like language, model selection). For the API key and prompts, the app should save them on change (with confirmation or test, e.g., it might verify the API key by doing a test call or at least checking format).

* **UI Design for Settings:** This can be a simple scrollable settings page with sections. Important to group clearly which settings are general vs trainer-only (use headers like “General” and “Trainer Options”). Possibly hide trainer options entirely until key is entered to avoid confusing non-trainers.

* **Localization of Settings:** Since the app is multilingual, the settings page itself should also reflect the chosen language (except possibly the trainer key which might remain a specific word). For example, in French UI, it would show “Langue de l’application” instead of “App Language”.

### **4.5 Error Handling and Edge Cases (UX):**

* If the Google Drive connection fails or expires (token expired), the app will prompt the user to re-authenticate in order to fetch or save data. This might happen in the background and bring up the OAuth dialog as needed.

* If an OpenAI API call fails (due to no internet or an error like rate limit or invalid key), the app should show an error dialog to the trainer: e.g., “AI generation failed: \[error\]. Please check your API key and network, or try a smaller request.” The trainer can then correct the issue. The UI should not freeze; always allow canceling out of a waiting state if it’s taking too long.

* If the user tries to use trainer features without entering the key, the app will prevent those actions and possibly ask for the key. For instance, if somehow a user navigated to an edit screen, it would either not show or would be read-only.

* Drive quota: If the user’s Drive is full or they hit storage limits, uploads will fail. The app should catch this and inform the user (“Google Drive storage full, cannot upload image”).

* Network offline: For end users, if offline, just use cache. If they try to refresh while offline, maybe a toast “No connection \- showing cached content”. For trainers, if offline and they attempt to save or use AI, it should warn or queue actions.

* Updating the app: If a new version of the app changes the JSON schema, ensure backward compatibility or migration. E.g., if we add new fields, older scenarios without them should still load (just default those fields). This can be handled in code with schema versioning if needed (not in this PRD scope but keep in mind).

By carefully handling these flows, the app ensures a smooth experience for both content consumers and creators. The separation of modes keeps the UI from overwhelming the end user while still packing powerful creation tools for trainers behind the scenes.

## **5\. Autorisations & Sécurité (Permissions & Security)**

This section details the necessary permissions the app will require, and how security and privacy of user data are handled.

### **5.1 Application Permissions**

Given the functionality, the app will request the following permissions from the user:

* **Google Drive Access (OAuth Scope Permissions):** Through the OAuth process, the user grants the app access to their Google Drive. We will use a scope that is as limited as possible, for example:

  * `https://www.googleapis.com/auth/drive.file` – This scope allows read/write access to files created or opened by the app in the user’s Drive. Using this scope, the app can only see the files it has created or explicitly opened via a file picker. This is ideal if we let the user pick the folder or file. Alternatively:

  * `https://www.googleapis.com/auth/drive.appdata` – Not suitable here because we want the files to be user-visible in Drive.

  * `https://www.googleapis.com/auth/drive` (Full Drive access) – We likely **do not need full scope**, and it’s better to avoid it. We can use `drive.file` combined with a file picker for selecting an existing folder, or instruct the user to place scenario files in a specific folder created by the app. If necessary, `drive.readonly` or `drive.metadata` could be used just to list file names if some other scheme is used.

  * In summary, the exact scopes will be configured to allow the needed file operations on the specific folder. The user will see a consent screen explaining this access. OAuth 2.0 ensures the app never sees the user’s password, just an access token.

* **Internet Access:** The app requires general network access (to call Google Drive APIs and OpenAI API). On Android, this is usually automatically granted by having the appropriate permission in the manifest (`android.permission.INTERNET`). On iOS, no explicit permission is needed in Info.plist for internet. This is a standard requirement for any networked app.

* **External Storage / Photos Access:** For uploading images from the device:

  * On Android, to allow the user to pick an image from gallery or file system, we might need permission to read external storage (`READ_EXTERNAL_STORAGE`). However, modern Android (API 30+) often uses scoped storage or the picker doesn’t require explicit permission if using certain APIs. If using an image picker library, it might handle permissions. If not, we’ll include it in the manifest and request at runtime when first needed ([How to Integrate Google Drive APIs & Use Google Drive as Storage Bucket for flutter Application? | by Arsalan umar | Medium](https://arxlan40.medium.com/how-to-integrate-google-drive-apis-use-google-drive-as-storage-bucket-for-flutter-application-2c1daabd47d1#:~:text=For%20now%2C%20we%20are%20just,xml)).

  * On iOS, to access the photo library, we need to add a usage description in Info.plist (like `NSPhotoLibraryUsageDescription`) and the system will prompt the user for access when first using the picker. If we allow taking a new photo with the camera, we also need camera permission (`NSCameraUsageDescription` on iOS, and corresponding on Android).

  * The app should handle gracefully if the user denies photo access (just can’t add images in that case).

* **Local Notifications (Optional):** Not explicitly in requirements, but if we ever wanted to notify when new scenarios are added, etc. For now, not needed, so not requesting.

* **Prevent Sleep (Optional):** If scenarios are long reading content, we might consider keeping the screen awake while a scenario is open (to avoid screen locking mid-training). This would require a permission on Android (`WAKE_LOCK`). It’s a minor consideration and could be handled by just toggling the screen idle programmatically.

### **5.2 Security Considerations**

* **Storage of Credentials:**

  * The Google OAuth access token (and refresh token) will be stored securely by the OAuth library (Google Sign-In) or can be stored in Flutter Secure Storage (encrypted storage on device).

  * The OpenAI API key, entered by the trainer, is sensitive since it could be abused if leaked. We will store this API key in a secure manner on the device, e.g., using Keychain on iOS and EncryptedSharedPreferences on Android (via flutter\_secure\_storage). It will not be exposed or transmitted anywhere except to OpenAI’s API when making requests (over HTTPS).

  * The Trainer Secret Key is not highly sensitive like an account password, but it should be kept somewhat secret to avoid unauthorized edits. The key might be hardcoded in the app or fetched from a remote config in a real deployment. In this scenario, we assume it’s a constant or user-provided value. If hardcoded, anyone decompiling the app could find it, but since this is not meant for public distribution widely, it’s acceptable. If it were more public, a more secure auth for trainers would be warranted.

* **Data Privacy:**

  * All scenario content is stored in the user’s Google Drive. This means the user’s private training content is under Google’s security and their account’s control. We do not send this content to any server except when the trainer uses AI. In that case, the content of the scenario (or prompt) is sent to OpenAI’s servers to generate text. Trainers should be informed that using AI generation will share that scenario text with OpenAI’s API (which is subject to OpenAI’s data policies). If the content is sensitive, they should be aware of this. This could be mentioned in a disclaimer on the generation prompt dialog.

  * The app itself does not collect analytics or personal data beyond what’s needed for functionality. If any usage data is collected (not specified here), it should comply with privacy laws and ideally also be minimal.

* **Authentication & Access:**

  * Only authenticated users can access the scenario files on Drive. If a user disconnects or loses auth, the app cannot read/update content until re-authenticated.

  * If multiple devices access the same Drive account, they all have equal capability to edit if they know the trainer key. There’s no separate authentication for trainers vs learners beyond that key.

  * If a trainer wants to share scenarios with learners without giving edit access, they could simply share the Google Drive folder with those learners’ Google accounts and have them connect to it. The learners, not knowing the secret key, would only use the app in read-only mode. This implies another security point: **if a learner connects to a folder where scenarios are stored, they can technically read all scenario JSON (which is fine) and also images. They cannot modify them in-app without trainer mode. They could theoretically go outside the app and edit the JSON in Drive if they have edit rights on that folder.** So in a scenario where trainers share the folder with learners, they might give view-only access. But Google Drive doesn’t have view-only for JSON easily (they could mark files as view only). This is outside our app’s control, but worth noting as a content management consideration.

  * The app might in future implement a more robust user system to separate trainer vs learner roles with different accounts, but that's beyond scope. For now, the secret key is the gate.

* **Integrity of Data:**

  * Since the content is user-editable JSON, there is a risk that improper formatting or manual edits could break it. The app should validate JSON structure when loading. If a JSON file is corrupt or missing required fields, the app should catch the error and possibly skip that scenario with an error message. It should not crash. It can notify the trainer that scenario X has invalid format.

  * The `lastUpdated` field could potentially be out of sync if someone manually edits the file. The app mainly uses it for info and cache; the Drive mod time is more reliable for sync.

  * There’s no encryption of the content at rest (since it’s on Drive, presumably the user trusts Google’s protection; if needed the user could encrypt files themselves, but then the app couldn’t read them, so not applicable here).

* **OpenAI Usage Limits:**

  * The app should set reasonable limits on AI usage to avoid excessive cost: e.g., maybe warn if generating a scenario with too many scenes or calling too frequently. But generally, it will be up to the trainer’s OpenAI account settings (they might have a quota or spend limit). We will ensure each API call is distinct and not loop unexpectedly.

  * We should also use the official API endpoints with the API key in the Authorization header (no sensitive info in URLs etc.), all over HTTPS for confidentiality.

In summary, the app respects the principle of least privilege (only asking for Drive access needed, etc.), secures sensitive keys, and ensures that a casual user cannot accidentally or maliciously alter content without the secret key. Google Drive acts as a secure storage and OpenAI as a tool, both integrated in a way where the user maintains control over their data.

## **6\. Cas d’Utilisation de l’IA (AI Use Cases & Integration)**

This section focuses on how exactly the app leverages OpenAI’s models to assist trainers, including the types of prompts, expected outputs, and how the integration is structured.

### **6.1 AI-Powered Scenario Generation**

One of the key use cases is allowing the AI to generate an entire scenario. This is particularly useful for rapidly prototyping a training scenario or getting inspiration.

* **Trigger:** The trainer selects “Generate New Scenario with AI” (from an Add dialog or a menu).

* **Input to AI:** The app needs to formulate a prompt to instruct the AI. There are two methods:

  * **Using Prompt Presets:** The trainer selects a preset template prompt from their saved presets. The app then presents a form to fill in any placeholders. For example, a preset might be: *“Create a workplace training scenario in **{language}** about **{topic}**. Include **{numScenes}** scenes, each with a problem and resolution. The scenario should be aimed at **{audience}**.”*. The trainer enters: language=French, topic=“client difficile”, numScenes=3, audience=“nouveaux employés”. The app composes the final prompt string.

  * **Ad-hoc Prompt:** The trainer writes a freeform prompt. They might just type “Give me a 3-scene scenario about handling an angry customer on the phone, in French.” The app will take that as is.

* **Model Call:** The app sends this prompt to the OpenAI **completion/chat API**. Likely using the ChatGPT style endpoint (since the models mentioned GPT-4.1 are chat models). It would use a system message to instruct format if needed, or just rely on prompt.

  * We may instruct the model to output JSON in the exact schema. This is tricky but possible by telling the model: “Respond ONLY in JSON format as follows: { ...schema... } without explanations.” The model hopefully returns well-structured JSON. We might have to adjust if the model returns text.

  * Alternatively, we allow the model to just write out the scenario text and then we parse it. But it’s safer to request JSON format for easier parsing. Since OpenAI models can follow examples, we could include an example structure in the prompt.

  * This might require GPT-4 level capability; simpler models might not reliably output JSON.

* **Output Handling:** The app receives the response. If it’s JSON, parse it. If it’s textual (like a narrative description of scenes), the app might need to do an intermediate step of parsing it into the JSON format (this is complex, so ideally we aim for JSON directly).

* **Populating the App:** The generated scenario is loaded into the editor. The trainer can then review:

  * Check if titles make sense, if content fits their need.

  * Edit any part that seems off. For example, the AI might have made assumptions that need tweaking.

  * Add images to scenes/problems as needed (AI won’t provide images).

* **Saving:** The scenario can then be saved to Drive like any other.

This use case dramatically speeds up content creation. However, trainers will be coached (perhaps via a tooltip or user guide) to always review AI output since it might contain inaccuracies or undesirable phrasing.

### **6.2 AI-Assisted Scene/Problem Creation**

In cases where the trainer has a scenario outline but wants help filling in details:

* **Generate Scene Description:** If a scene exists with just a title, the trainer can ask AI to write a description for it. The prompt might be something like: “Write a scene description for a training scenario. Scene title: X. The scene should set up \[some context\].” The model returns a paragraph or two which we fill into the description field.

* **Generate Problems:** If a scene has a description, the trainer can request a set of problems:

  * Prompt idea: “Based on the above scene description: \[include scene text\]. Propose 2 problems that a learner should solve, each with a brief title, description, and an ideal resolution, in French.” The model’s answer might not be JSON, but we can instruct it to list them in some format. We then parse and create problem entries.

  * Or we have it output directly JSON array of problems to insert.

* **Generate Resolution:** On a problem card, if the trainer wrote a problem but not the resolution, we can prompt the model: “Provide a detailed resolution to the following problem in a training context: \[problem description\]. The answer should guide the learner.” Then fill that in the resolution field.

In all these micro-generation cases, the app knows the context (current scenario’s language, possibly other scenes). We include that context in the prompt to maintain continuity and style. This context inclusion is what was referred to with *maintain chat history or document awareness*. Concretely, we might maintain an ongoing conversation with the model for each scenario in the background:

* System message could state the overall goal (e.g., “You are an AI assistant that helps create interactive training scenarios.”).

* The conversation might start with the user’s high-level instructions or existing scenario content, and the model’s outputs fill in new parts. However, implementing a full chat might be too advanced; a simpler approach is to send a fresh prompt each time with relevant content embedded.

We must be mindful of token limits; sending the entire scenario each time might not scale if scenario is long. Instead, sending just relevant parts (like just the current scene’s info when generating problems for it) is better.

### **6.3 Translation via AI**

This case reuses AI but specifically for translation:

* **Prompt for Translation:** The app would take a scenario’s content (all text fields) and ask the model to translate it. This could be done field by field or in one go:

  * One approach: “Translate the following training scenario from French to English. Preserve the format and structure. \[Then provide the JSON or a text representation\].”

  * GPT can likely handle a decent chunk of text. We may provide it as a system message "You are a translator..." and user message with the content.

* **Output:** Ideally, we want the translated scenario in JSON format as well. If that’s tricky, the app could piecewise translate each scene:

  * For each scene title/desc and each problem title/desc/resolution individually. This ensures small prompts and easier mapping of output to fields.

  * This might be more reliable but also more API calls (costly if many fields).

  * Or prompt it for a structured output.

* **Post-Processing:** After getting translations, the app creates a new scenario JSON with identical structure but new language code and translated text. The trainer can then verify if any translation is awkward. Domain-specific terms might need tweaking.

### **6.4 AI Model Selection & Usage**

* We assume OpenAI’s GPT-4.1 mini/nano correspond to endpoints (for example, `gpt-4-0613` vs a hypothetical smaller model). The app configuration (in settings) will let the trainer choose.

* If a faster but less accurate model is chosen, the trainer might use it for drafts and then refine, or use the better model for final generation.

* All calls are made via a common service class in the app that takes care of adding the API key in headers, constructing the HTTP POST requests (likely to `https://api.openai.com/v1/chat/completions`).

* We will parse the JSON response from OpenAI. For chat, the important part is `choices[0].message.content` which contains the model’s answer. If using completion, it’s `choices[0].text`. We choose whichever suits better (chat models are the modern approach).

* The integration will use Dart’s HTTP or an OpenAI Dart package ([dart\_openai | Dart package](https://pub.dev/packages/dart_openai#:~:text=An%20open,models%20into%20their%20Dart%2FFlutter%20applications)) to simplify usage. For instance, using a community Dart SDK can abstract away some details and ensure correct endpoints ([dart\_openai | Dart package](https://pub.dev/packages/dart_openai#:~:text=This%20library%20provides%20simple%20and,E%20image%20generation%2C%20and%20more)).

* **Error Handling for AI:** If the API key is invalid or model not available, the app should catch the error (OpenAI API returns an error JSON). We will surface a user-friendly message. If the output is not as expected (e.g., not valid JSON when we asked for JSON), the app might attempt a second try or inform the trainer that generation partially failed (maybe provide whatever text came and let them copy paste).

* Rate limiting: OpenAI might have rate limits; our usage is likely low volume (a few calls when trainer actively editing). If hit, just tell user to wait.

### **6.5 AI Use Case Examples**

* **Example 1: Full Scenario Generation Prompt (French)**:

  * Prompt sent: *“Crée un scénario de formation en **français** sur le thème de **la cybersécurité au bureau**. Le scénario doit comporter **3 scènes**, et chaque scène aura une description, puis un problème avec sa résolution détaillée. Le public cible est **des employés non techniciens**. Réponds uniquement en JSON avec le format convenu des scénarios.”*

  * Expected model output: A JSON text with 3 scenes, each having a realistic cybersecurity scenario, perhaps something about phishing email in scene 1, USB drive in scene 2, etc., all in French.

  * The app then uses that output.

* **Example 2: Scene Problem Generation Prompt (English)**:

  * Context: The trainer wrote a scene about “Customer angry about billing”.

  * Prompt: *“Given the scene description: 'A customer calls, furious about a billing error... \[more\]', propose two problems (with title, description, resolution) for the learner to solve in this scenario. Respond in JSON with an array of problem objects.”*

Output: The model might return:

 \[  
  {  
    "title": "Calming the Customer",  
    "description": "The customer is shouting about being charged twice on their bill. How do you respond to de-escalate the situation?",  
    "resolution": "Begin by apologizing sincerely for the inconvenience... \[more\]."  
  },  
  {  
    "title": "Investigating the Issue",  
    "description": "After calming the customer, you need to find the root cause of the billing error. What steps do you take to investigate the issue while keeping the customer informed?",  
    "resolution": "Reassure the customer you're looking into it. Check their billing history... \[more\]."  
  }  
\]

*   
  * The app would insert these two problems into the scene’s problem list.

* **Example 3: Translation Prompt**:

  * French to English, perhaps done field by field. For a given text:

  * Prompt: *“Translate to English: 'Il est conseillé d'intervenir calmement pour apaiser les esprits...'”*

  * Model: "It is advisable to intervene calmly to defuse the situation..."

  * The app places that in the resolution of the English scenario.

The AI integration transforms the app into an intelligent assistant for content creation. By adjusting prompts and using the model’s capabilities, trainers can dramatically reduce writing time or get past writer’s block. The key is to make the UI for using AI intuitive (e.g., clearly labeled buttons like “💡 Generate with AI” or “🌐 Translate scenario”) and ensure the outputs are editable.

Finally, the use of AI is optional; trainers can ignore it if they prefer to write everything manually. The PRD ensures that the presence of AI features does not impede manual editing at any time.

## **7\. Paramètres & Préférences (Settings Recap)**

*(This section summarizes the configuration options available in the app, some of which were touched upon in flows and features, but consolidating here for clarity.)*

### **7.1 General Settings (User Facing)**

* **Connected Google Account:** Displays the user’s Google account email that is currently linked. Allows disconnection or switching account. (When disconnecting, the app might clear cached data for security.)

* **Drive Folder Selection:** Shows the name of the Drive folder being used for scenarios. Tapping it allows the user to pick a different folder (through Google’s file picker or by entering a folder ID/share link). Only one folder can be active at a time.

* **App Language Selection:** As described, choose UI language from a list. This setting persists (store in local storage) so that on next app launch, the chosen language is applied.

* **Theme (Optional):** Not mentioned in requirements, but the app could allow light/dark mode toggle as a user preference. Since not specified, we assume it follows system theme or has a default design.

* **About:** Info on version, perhaps a link to rate app or contact support.

### **7.2 Trainer Settings (Requires Unlock)**

*(Only visible after entering trainer secret or perhaps visible but disabled until then.)*

* **Trainer Mode Activation:** Input for the secret key (if trainer mode not yet active). If active, this could show “Trainer mode: On (Key accepted)” and maybe give an option to turn off or logout of trainer mode.

* **OpenAI API Key:** Field to input/edit the key. Possibly a “Test Key” button to verify it can retrieve model list or a simple test completion (optional).

* **Preferred AI Model:** Dropdown of model options (with maybe a short description like “(faster)” or “(most advanced)” next to names).

* **AI Prompt Presets Management:**

  * List existing presets. Selecting one opens an editor where they can change the name or text.

  * Add new preset (opens a blank template editor).

  * Delete preset (with confirmation).

  * Some default presets might be provided initially (especially if the trainer is not sure how to write prompts). The trainer can modify or remove those if they want.

* **Content Sync Options:** Option to trigger a manual **Sync Now** (same as refresh button functionality) from settings, and possibly a toggle for auto-sync at startup (though we likely always sync at startup by design).

* **Cache Management:** A button to **Clear Cache** which would delete local copies of scenario files and images. Use case: free up space or force a full re-download if things got out of sync.

* **Export Data (Optional):** Perhaps allow exporting all scenarios as a zip (could be done by just going to Drive actually). Not needed since they’re already in Drive.

* **Import Data (Optional):** If someone gave the user a bunch of scenario files (JSON and images) outside of the connected folder, the user could place them in the folder manually. A direct import function could let them select a JSON to load, but since Drive is main source, not needed.

### **7.3 Defaults and Constraints**

* The default Drive folder name the app will create (if none chosen) can be “ScenarioTraining” or localized “FormationScenarios”. This can be hard-coded or configured on build.

* The secret trainer key would be set in code (for example, `const trainerKey = "TR!@#123"` or something). We must ensure this is provided to the trainer separately and possibly can be changed for security (maybe by editing a config file or environment variable in the app).

* **Supported Languages** for UI: Initially French (fr) and English (en). The code will be prepared to add others. For scenario content, any language code could be used, but the app UI only covers the ones it knows for interface. Possibly we restrict scenario language to ones the UI supports or at least to ones OpenAI can handle (OpenAI can handle a lot, so not a big limit).

* For OpenAI, we assume the API key given has access to GPT-4. If not, maybe the user could also use GPT-3.5, etc. We can include an option for “gpt-3.5-turbo” if needed as a model (faster and cheaper, in case).

* **AI Presets default example:**

  1. “Blank Slate” – no preset, just an empty prompt (in case they want to type from scratch every time).

  2. “General Scenario” – a template as described for multi-scene scenario generation.

  3. “Single Scene Brainstorm” – maybe a prompt to help generate one scene’s content ideas.

  4. “Translate” – though we handle translation separately, a preset might not be needed for translation as it’s a dedicated feature.

* **Logging:** The app might log operations (like “Saved file X” or “API call to OpenAI took Y seconds”) internally for debugging, but it won’t expose logs to the user except in a debug mode if needed.

In sum, the settings allow customization and control over the app’s integrations and content without overwhelming a regular user (who might only use the Drive connect and language options).

## **8\. Architecture & Technical Design (Architecture)**

In this section, we outline the technical architecture of the application, including the division of components, how data flows, and the technologies/ frameworks used. ([Google Drive API overview  |  Google for Developers](https://developers.google.com/drive/api/guides/about-sdk))e】 *Figure: High-level architecture of the Scenario Training app. The Flutter client communicates directly with Google Drive (for data storage via the Drive API) and OpenAI’s API (for content generation) over HTTPS, using OAuth for Drive access. End users and trainers use the same app; a secret key enables editing capabilities for trainers.*

### **8.1 Client-Only Flutter Application**

* The entire app is built with **Flutter**, leveraging Dart, and is deployed as a mobile application (targeting Android and iOS primarily). Being client-only means there is **no custom backend server**; all data and computation (aside from calling external APIs) happen on the device. This greatly simplifies deployment and ensures user data (scenarios) remain under user control (on their Google Drive).

* **State Management:** The app likely uses a state management approach (such as Provider or BLoC) to handle the scenario data and UI state (edit mode toggle, loading states for API calls, etc.). This ensures a responsive UI even as async operations (Drive fetch, AI calls) happen.

* **Data Layer:** This consists of:

  * A local database or storage (for cached JSON and images).

  * Services for Google Drive and OpenAI.

  * Repositories or controllers that mediate between the UI and these services, handling caching logic and so on (typical app architecture approa ([Supercharge Your Flutter Apps with Google's App Architecture. |](https://medium.com/@henryifebunandu/enhancing-your-flutter-apps-with-this-app-architecture-and-feature-first-approach-14502cb242e1#:~:text=Supercharge%20Your%20Flutter%20Apps%20with,a%20database%2C%20local%20storage)) ([Which pattern/architecture follow to build Flutter app? \- Stack Overflow](https://stackoverflow.com/questions/67420479/which-pattern-architecture-follow-to-build-flutter-app#:~:text=study%20and%20apply%20considering%20that,am%20a%20beginner%20in%20Flutter))1】).

* **UI Layer:** Flutter widgets representing screens: ScenarioListScreen, SceneScreen, ProblemScreen, SettingsScreen, etc., plus forms and dialogs for editing. The UI reacts to state changes (like new data loaded, or switching to trainer mode).

* The app is organized to separate **view logic** from **business logic**, making it easier to maintain (for example, using MVVM or similar pattern).

### **8.2 Google Drive Integration**

* The integration uses Google’s APIs to allow the app to treat Drive as the backend storage. Essentially, the app acts as a **Google Drive App** in Google’s ter ([Google Drive API overview  |  Google for Developers](https://developers.google.com/drive/api/guides/about-sdk#:~:text=Google%20Drive%20API%20The%20REST,open%20files%20within%20your%20app)) ([Google Drive API overview  |  Google for Developers](https://developers.google.com/drive/api/guides/about-sdk#:~:text=The%20Google%20Drive%20API%20lets,application%20using%20the%20Drive%20API))3】:

  * **OAuth2 Authentication:** The app uses the Google Identity SDK (`google_sign_in` for Flutter) to handle user authentication. This yields an OAuth token with the requested scopes. Under the hood, `google_sign_in` might use a Google-provided secure webview or the Google app to authenticate.

  * After sign-in, the app obtains an `accessToken` which it uses with Google Drive API calls. The token is included in HTTP Authorization headers.

  * **Drive API calls:** The app can use the HTTP REST endpoints directly or through a Dart package (`googleapis` package which includes a Drive API client). For example, to list files in a folder we call `https://www.googleapis.com/drive/v3/files?q='<FOLDER_ID>'+in+parents`.

  * We specify `fields` to only retrieve needed info (like name, id, modifiedTime).

  * To download a JSON file, we call the Drive files get API with `alt=media` to get file content.

  * To upload/update, we either use the Drive v3 update API or the simple content upload if file small.

  * The Medium article referenced by Arslan Um ([How to Integrate Google Drive APIs & Use Google Drive as Storage Bucket for flutter Application? | by Arsalan umar | Medium](https://arxlan40.medium.com/how-to-integrate-google-drive-apis-use-google-drive-as-storage-bucket-for-flutter-application-2c1daabd47d1#:~:text=In%20this%20article%2C%20we%20will,validation%20and%20afterward%20got%20to))7】 indicates a pattern of using Google sign-in and then the `googleapis` library to manage files, which is what we will follow.

* **Folder and File structure details:**

  * On first run after sign-in, if the user didn’t pick an existing folder, the app may create a folder by making a POST request to Drive API with a File resource of mimeType `application/vnd.google-apps.folder` and name “TrainingScenarios” (or localized).

  * The folder ID returned is stored.

  * For any new scenario, create a file with mimeType `application/json` and name as given, parent \= folder ID. Also create a folder (mimeType folder) for media with name like `<scenarioTitle>_media`, parent \= main folder.

  * The scenario JSON’s Drive file ID and the media folder’s ID can be stored as metadata in app (maybe in the JSON we could even store its own file ID for reference, though not strictly needed).

  * When listing scenarios, we might just list `.json` files in the folder. Or perhaps tag them with a specific property or name pattern if needed to distinguish from any other file. Assuming that folder contains only our scenario files and subfolders, listing by mimeType \= json in that folder is fine.

  * The app should ignore the media subfolders when listing scenario files (filter out mimeType folder or known “\_media” suffix).

* **Offline Considerations:** The first run obviously requires internet to fetch scenarios. But after that, the local cache suffices for reading. For writing (trainer editing), eventually an internet connection is needed to sync to Drive. The app could allow continuous editing offline and then a single sync, but the complexity of merge arises if content changed on Drive in between. To keep scope reasonable, we expect trainers to be online when editing to immediately save. If offline, perhaps limit editing to minor tweaks and caution user.

* **Drive API Limits:** Drive has usage quotas (queries per second, etc.), but our usage is low (list files occasionally, download small files, upload small files on save). This should be well within free quotas. If a trainer uploads many large images, that’s only limited by the user’s own Drive storage.

* **Error cases:** If Drive API returns errors (expired token, etc.), the app handles by reauthenticating or showing a message. Possibly use refresh token to get new access token automatically (the sign-in library should manage that).

* **Alternate approach (not chosen):** One could have used Firebase or a custom backend. But the Drive approach was specifically requested, leveraging user’s existing cloud storage, which is a unique design but suitable for personal/small-team usage.

### **8.3 OpenAI API Integration**

* The app will integrate with OpenAI via its RESTful API. The relevant endpoints are:

  * `/v1/chat/completions` for GPT-4 (and 3.5) chat models.

  * Possibly `/v1/completions` for older completion models if needed.

* **Library or HTTP:** Options include using the `dart_openai` packa ([dart\_openai | Dart package](https://pub.dev/packages/dart_openai#:~:text=An%20open,models%20into%20their%20Dart%2FFlutter%20applications))2】 which wraps the API, or making direct HTTP calls using `http` package.

  * Using `dart_openai`, for example, one could set the API key and then call `OpenAI.chat.create(...)` with the model, messages, etc. It simplifies some details like streaming if we wanted it.

  * For initial simplicity, direct calls might be fine: we will craft the HTTP request with the necessary JSON payload and parse the JSON response.

* **Prompt Building:** The logic that prepares prompts will be implemented likely in a service or utility class. It will take parameters (context content, desired action like “generate scenario” or “translate”) and output a prompt string or chat message list.

  * We might utilize system messages for role instruction and user message for actual prompt content.

* **API Key Management:** We already covered the storage. At runtime, the key is retrieved from secure storage and included in the Authorization header (`"Authorization": "Bearer <APIKEY>"`).

* **Model selection:** The chosen model name (e.g., `"gpt-4-1-mini"`) will be used in the API request’s `model` field. If using the `dart_openai` library, we ensure it supports those model names (it likely will if the API does).

* **Asynchronous calls:** The AI requests will be async. The UI will show a loading indicator when waiting for a response (like a progress bar, spinner, or a placeholder in text fields saying “Generating…”). If streaming results (not required here), we could show text as it comes, but probably simpler to wait for final output then display.

* **Error handling:** If an API call fails, catch the exception or error response. Show a dialog or error message to user. Possibly log the error for debugging. The user can try again or check their key, etc.

### **8.4 Local Data Storage**

* We use **local persistent storage** for:

  * JSON cache: Possibly stored as individual files (one per scenario) in the app’s documents directory. This is straightforward—just save the JSON string to `<appDir>/<scenarioTitle>.json`. Alternatively, store all scenarios in a single SQLite table, but that’s overkill and adds complexity. Since scenarios are separate files naturally, keeping them as such is fine.

  * Images cache: Save images in the app’s cache or files directory. We can mirror the structure (maybe have subfolders for each scenario similar to Drive). Or just save by file ID or name ensuring uniqueness (e.g., prefix with scenario title). For cleanliness, subfolders per scenario make deletion easier if a scenario is removed.

  * Other: The prompt presets and settings can be stored either in `SharedPreferences` (simple key-value store) or as a small JSON file. Flutter’s `shared_preferences` is good for small data like API key, language setting, etc. For larger data like presets list, it can still be stored as a single JSON string in prefs, or use a small file. We’ll likely use `shared_preferences` for simplicity (the presets list can be JSON-encoded into a string).

* On app startup, load all settings (language, etc.) then initiate Drive sync.

* After sync, store updated cache and use in UI.

### **8.5 Architecture Diagram Explanation**

Referring to the figure provided above (the Google Drive API relationship diagram, slightly adapted for our context):

* The **Flutter App** (client) is at the center. It has two main external interactions:

  1. With **Google Drive**: The app uses the Drive REST API to load and save files. OAuth 2.0 stands in between as the gatekeeper for acce ([Google Drive API overview  |  Google for Developers](https://developers.google.com/drive/api/guides/about-sdk#:~:text=OAuth%202,files%20inside%20the%20shared%20drive))0】. Once authenticated, the app can perform file operations. In the diagram, the arrows show the app making Drive API calls (list, download, upload). Google’s servers handle these and read/write from the user’s **My Drive** storage (or a shared drive if that was used).

  2. With **OpenAI API**: The app communicates with OpenAI’s cloud service by sending the content (prompts) and receiving AI-generated text. This requires internet but no user login (just the API key).

* **Local Cache**: The app also writes to local storage (not depicted in the figure, but conceptually an internal component). When a scenario is fetched from Drive, the app saves it locally. On subsequent app launches, the app can read from the cache first (fast startup) then refresh in background. This improves performance and offline availability.

* **End User vs Trainer**: They use the same app codebase. The only difference is an internal flag `isTrainerMode` that unlocks editing UI. In architecture, that’s just part of the UI logic. It doesn’t change how data flows externally except that trainers will perform upload operations and AI calls, whereas end users might only perform download operations (read-only).

* The **Drive folder** effectively acts as a mini database. If we think in terms of layers: the Drive folder is the persistent layer, and the local cache is a synchronized copy. Our app logic ensures consistency between them.

### **8.6 Sequence of Operations Example**

To illustrate how components interact, consider a trainer editing a scenario and generating a new one with AI:

1. Trainer opens settings, enters secret key (UI-\> sets state to trainer mode).

2. Trainer taps “Add Scenario (AI)”. (UI event)

3. UI calls the ContentService \-\> which might call AIService to generate scenario.

4. AIService formulates prompt (using PresetService to get template, etc.) and calls OpenAI API via HTTP.

5. Response comes back, AIService parses JSON.

6. ContentService creates a new Scenario object, and invokes DriveService to save it (or marks it unsaved until edited? Could save immediately).

7. DriveService uses Google API to create the new file on Drive (with provided JSON content).

8. On success, it returns file ID, etc. The ContentService updates local cache (save JSON file locally).

9. UI now navigates to scenario edit view loaded with this new content. Trainer sees it and maybe edits a bit.

10. Each edit triggers ContentService to update model and call DriveService to update file content (or batch them on a debounce timer to avoid too frequent saves).

11. Meanwhile, if an image is added, the MediaService is called which uses\# Document: Application de Formation par Scénarios (PRD)

## **Text-to-Speech (TTS) Functionality**

* **TTS on All Text Content:** The app shall provide text-to-speech playback for all textual content in a scenario. This includes scene titles, scene descriptions, problem statements/questions, and resolution/explanation texts. Users should be able to have any on-screen text read aloud for accessibility and convenience.

* **Playback Controls:** Offer standard audio playback controls for TTS. Include at minimum **Play** (to start or resume speech), **Pause** (to pause speech), and **Restart** (to restart reading from the beginning of that section). These controls should be intuitive (e.g. using familiar icons) and remain accessible while TTS audio is playing, allowing the user to pause or restart at any time.

* **Section-Specific Playback:** Implement TTS on a per-section basis. Users can independently play or pause TTS for specific sections of the content rather than one long narration for the whole screen. For example, a user might play the audio for the scene description without automatically triggering audio for the problem statement, and vice versa. Each distinct text block (scene description, problem description, resolution, etc.) should have its own TTS playback control.

* **Language Support:** TTS playback must use the language of the scenario’s content. Each scenario is written in a single language, so the TTS engine should be set to that locale for accurate pronunciation. (For example, a French scenario uses a French voice, an English scenario uses an English voice, etc.) The app should automatically select the appropriate language for TTS and ensure that only supported languages are used for each scenario.

* **Synchronized Highlighting:** As the text is spoken aloud, the corresponding text on screen should be visually highlighted in sync with the audio. Highlight the currently spoken sentence or paragraph (whichever granularity is feasible) to help the user follow along. The highlight should move progressively as narration advances (e.g. highlighting the current sentence being spoken, then moving to the next sentence once the first is finished)​[stackoverflow.com](https://stackoverflow.com/questions/66061777/how-to-highlight-the-current-word-dynamically-using-flutter-text-to-speech-plugi#:~:text=flutterTts,). This visual cue improves readability and user engagement.

* **Cross-Platform Support:** All TTS features must work seamlessly on both Android and iOS devices. The implementation should leverage each platform’s native text-to-speech capabilities to ensure reliability and performance. The user experience (controls, highlighting, language selection) should remain consistent across platforms. (Ensure, for instance, that both Android and iOS can perform TTS with equivalent functionality and quality.)

* **TTS Engine Selection:** Use a high-quality, widely compatible TTS engine for speech synthesis. Prefer using the **built-in native TTS engines** on each platform – for example, Google Text-to-Speech on Android and AVSpeechSynthesizer (Apple’s built-in TTS) on iOS – to allow offline usage and maximize compatibility. These native engines typically support a range of languages and offer reasonably natural voices. Ensure that the chosen engine/voices cover all languages needed for the scenarios and produce clear, natural-sounding speech. If a required language or a higher-quality voice is not available via the on-device engine, the app should **fallback to a cloud-based TTS service** for that content (e.g. Google Cloud Text-to-Speech or Amazon Polly). This fallback should be seamless to the user – use online TTS only when necessary for unsupported languages, and use offline/native TTS whenever possible to avoid requiring internet connectivity.

* **Technical Implementation (Flutter):** Use a Flutter plugin (such as `flutter_tts`) to implement the TTS functionality, as it provides a unified API that supports both Android and iOS​[pub.dev](https://pub.dev/packages/flutter_tts#:~:text=A%20flutter%20plugin%20for%20Text,macOS%2C%20Android%2C%20Web%2C%20%26%20Windows). Key implementation recommendations include:

  * **Flutter TTS Plugin:** Leverage the `flutter_tts` plugin (or a similar library) for cross-platform TTS. This plugin supports speaking, pausing, stopping, and provides methods to set the speech language, rate, pitch, and volume​[pub.dev](https://pub.dev/packages/flutter_tts#:~:text=,%E2%9C%85%20get%20voices). It also allows retrieving available languages and voices, which can be used to ensure the correct locale/voice is selected for each scenario.

  * **Playback Control Integration:** Map the plugin’s methods to the UI controls. For example, call `flutterTts.speak(<text>)` to play, `flutterTts.pause()` to pause, and if needed `flutterTts.stop()` to stop or restart (you can also restart by stopping and calling speak again from the beginning of the text). Ensure that when a user hits “Restart”, the playback position resets to the start of that section’s text. Maintain state (e.g., whether a section is currently playing or paused) so the UI can reflect the proper icon (Play vs Pause).

  * **Language and Voice Selection:** Before playing audio for a section, set the TTS engine’s language to the scenario’s language locale (e.g., `flutterTts.setLanguage("fr-FR")` for French). The plugin provides lists of supported languages and voices​[pub.dev](https://pub.dev/packages/flutter_tts#:~:text=,%E2%9C%85%20get%20voices); use this to confirm the desired language is available. Where multiple voices are available in a language, a default voice can be chosen (optionally, provide a setting to choose a voice, though this can be a future enhancement).

  * **Progress Callback & Text Highlighting:** Utilize the plugin’s progress callback (e.g. `flutterTts.setProgressHandler(...)`) to synchronize highlighting. The TTS plugin can callback with the indices or words as they are spoken​[stackoverflow.com](https://stackoverflow.com/questions/66061777/how-to-highlight-the-current-word-dynamically-using-flutter-text-to-speech-plugi#:~:text=flutterTts,), allowing the app to determine which part of the text is currently being read. Using this, implement a mechanism to highlight the current sentence or phrase in the UI. For example, you might split the section text into sentences and as each sentence’s words are spoken, apply a highlight style to that sentence. This requires updating the UI in real-time (on the main thread) as the speech progresses.

  * **Platform-Specific Considerations:** Account for minor differences between Android and iOS TTS. On **Android**, ensure the required language voice data is installed on the device. (The plugin can check if a language is installed via methods like `isLanguageInstalled`​[pub.dev](https://pub.dev/packages/flutter_tts#:~:text=,%E2%9C%85%20set%20engine) and list available languages; if not installed, the app may prompt the user to download the language pack or automatically trigger the download.) Note that Android’s native TTS engine does not natively support pause/resume on all OS versions – the plugin implements a workaround using Android Oreo (API 26\) features to enable pause functionality​[pub.dev](https://pub.dev/packages/flutter_tts#:~:text=Android%20TTS%20does%20not%20support,is%20called%20after). Test that pause/resume works on the minimum supported Android version. On **iOS**, the AVSpeechSynthesizer works out-of-the-box; just ensure the correct language code is used. iOS will automatically use a default voice for that locale (users can download enhanced voices in iOS settings if desired for higher quality, but that is outside the app’s control). Also, be mindful of iOS’s silent mode switch – use an audio session category that allows TTS audio to play even if the phone is on silent, if appropriate.

  * **Offline vs. Online Fallback:** Design the TTS feature to work offline by default using on-device engines. An internet connection should **not** be required for TTS in supported languages as long as the device has the necessary language files installed​[github.com](https://github.com/dlutton/flutter_tts/issues/212#:~:text=dlutton%20%20%20commented%20,66). If using a cloud TTS fallback for some cases, implement it such that when the device is offline (or the service is unreachable), the app either: (a) falls back to a default on-device voice for that language (if available), or (b) informs the user that TTS is unavailable for that section. Ideally, the app could detect the lack of a local voice in advance and download it or warn the user. Caching audio is another consideration: if cloud TTS is used, the app might download and cache the spoken audio for a scenario ahead of time (e.g., at scenario download) so that playback is instant and available offline after caching. Ensure that any online TTS usage complies with privacy and data usage policies (since text content would be sent to an external service).

# **Flutter Project Best Practices Guide**

**Overview:** This guide provides best practices for a Flutter project that integrates **Flutter & Dart**, the **Google Drive API**, the **OpenAI API**, **Text-to-Speech (TTS)** capabilities, and **OAuth2 authentication**. It covers project structure, code modularization, dependency management, security of API keys, asynchronous programming, data storage and caching, performance optimization, accessibility, localization, as well as testing and debugging. In addition, it outlines the functional requirements for two user roles – **Trainer** and **Learner** – with their respective features and capabilities.

## **Project Structure and Organization**

Structure your Flutter project with clarity and **separation of concerns** in mind. Divide the code into logical layers – for example, a **UI layer** for presentation (widgets, views, view models) and a **data layer** for application logic (repositories, services, models)​[docs.flutter.dev](https://docs.flutter.dev/app-architecture/guide#:~:text=Separation,layer%20and%20the%20Data%20layer). This approach (often following an MVVM or Clean Architecture pattern) helps ensure each component has a single responsibility and well-defined boundaries. Organizing by feature or by layer are both viable strategies; the key is to pick a convention and apply it consistently so the team can add features in a uniform manner​[codewithandrea.com](https://codewithandrea.com/articles/flutter-project-structure/#:~:text=When%20building%20large%20Flutter%20apps%2C,how%20to%20structure%20our%20project)​[codewithandrea.com](https://codewithandrea.com/articles/flutter-project-structure/#:~:text=In%20practice%2C%20we%20can%20only,what%20app%20architecture%20to%20use). For instance, larger apps might use a *feature-first* folder structure (grouping all files for a feature together) or a *layer-first* structure (separate folders for UI, models, services, etc., with sub-folders per feature) – choose the one that best fits your team and project complexity, and stick to it for clarity and scalability.

## **Code Modularization**

As your project grows, consider splitting functionality into **modules or packages** for better maintainability. A modular architecture divides the app into smaller, independent pieces (e.g. a module for Google Drive integration, one for OpenAI services, one for TTS, etc.) rather than one monolithic codebase​[themomentum.ai](https://www.themomentum.ai/blog/modular-codebase-in-flutter---should-you-split-your-project-into-packages#:~:text=1,project%20management%2C%20enhanced%20team%20collaboration). You can organize modules by feature (e.g. authentication, content management) or by layer (e.g. presentation, domain, data) depending on what makes the code more understandable​[themomentum.ai](https://www.themomentum.ai/blog/modular-codebase-in-flutter---should-you-split-your-project-into-packages#:~:text=1,project%20management%2C%20enhanced%20team%20collaboration). Modularization offers benefits such as easier project management, improved team collaboration, and code reuse across projects or app versions​[themomentum.ai](https://www.themomentum.ai/blog/modular-codebase-in-flutter---should-you-split-your-project-into-packages#:~:text=3,reusability%20across%20different%20app%20versions). Keep in mind it also adds some complexity (setting up modules and managing their inter-dependencies)​[themomentum.ai](https://www.themomentum.ai/blog/modular-codebase-in-flutter---should-you-split-your-project-into-packages#:~:text=5,boundaries%20between%20components%20are%20beneficial), so weigh the trade-offs. If you do modularize, use Dart’s package system to create library packages for each module and manage them via the main app’s `pubspec.yaml`. Tools like **Melos** can help orchestrate multi-package projects (running tests, upgrades across modules) if your app is split into many packages​[themomentum.ai](https://www.themomentum.ai/blog/modular-codebase-in-flutter---should-you-split-your-project-into-packages#:~:text=3,project%20management%2C%20enhanced%20team%20collaboration). The goal is to encapsulate functionality (for example, all Google Drive related code in a module) so that each part can be developed and tested in isolation and replaced or updated with minimal impact on others.

## **Dependency and Package Management**

Manage your Flutter dependencies carefully to ensure a stable and up-to-date project. Use **pub.dev** packages for common needs (for example, use the official `googleapis` package for Drive API, `flutter_tts` for Text-to-Speech, or HTTP libraries for network calls) instead of reinventing the wheel. In your `pubspec.yaml`, specify version ranges for each dependency (using caret syntax like `^x.y.z`) rather than pinning exact versions​[docs.flutter.dev](https://docs.flutter.dev/packages-and-plugins/using-packages#:~:text=Suppose%20you%20want%20to%20use,specific%20versions%20when%20specifying%20dependencies). This allows Pub to resolve compatible versions and avoid conflicts while preventing breaking changes (e.g. `^5.4.0` allows updates up to but not including 6.0)​[docs.flutter.dev](https://docs.flutter.dev/packages-and-plugins/using-packages#:~:text=Suppose%20you%20want%20to%20use,specific%20versions%20when%20specifying%20dependencies). Commit the `pubspec.lock` file for applications to lock versions – Flutter uses this lockfile to ensure all developers and CI use the same package versions, making builds reproducible​[docs.flutter.dev](https://docs.flutter.dev/packages-and-plugins/using-packages#:~:text=When%20running%20,flutter%20pub%20get). Regularly review and update packages: you can run `flutter pub outdated` to see which dependencies have newer versions and get advice on updating them​[docs.flutter.dev](https://docs.flutter.dev/release/upgrade#:~:text=To%20identify%20out,the%20Dart%20pub%20outdated%20documentation). When adding new packages, use `flutter pub add` for convenience and to keep version constraints consistent. Remove any unused packages to slim down the app (unnecessary libraries increase app size and may impact performance)​[bacancytechnology.com](https://www.bacancytechnology.com/blog/flutter-performance#:~:text=10,File). For multiple modules, you can use path or git dependencies as needed for local packages​[docs.flutter.dev](https://docs.flutter.dev/packages-and-plugins/using-packages#:~:text=Packages%20can%20be%20used%20even,additional%20dependency%20options%20are%20available)​[docs.flutter.dev](https://docs.flutter.dev/packages-and-plugins/using-packages#:~:text=Git%20dependency), but be cautious with external Git dependencies for critical functionality (prefer published packages for reliability). Finally, ensure you differentiate **dev dependencies** (like build\_runner, test packages) from release dependencies to avoid bloating production builds. Regular dependency cleanup and updates will keep the project healthy and easier to maintain.

## **Secure Handling of API Keys and Credentials**

**Never hardcode API keys or secrets in your Flutter app code** – this is a critical security practice. Hardcoding keys (e.g. directly in a Dart file) risks exposing them to anyone who inspects your code or decompiles the app, leading to credential leaks​[dev.to](https://dev.to/harsh8088/flutter-best-practices-for-api-key-security-145m#:~:text=Important%3A%20Never%20hardcode%20API%20keys,Here%27s%20why%20it%27s%20not%20recommended). Attackers or even curious users could extract a Google API key or OpenAI secret and misuse it​[dev.to](https://dev.to/harsh8088/flutter-best-practices-for-api-key-security-145m#:~:text=Version%20Control%20Exposure%3A%20If%20you,key%2C%20compromising%20your%20app%27s%20security). Instead, use safer methods to inject and store secrets:

* **Build-time injection:** Pass API keys at compile time using Flutter’s `--dart-define` flags or environment variables. For example, define `flutter run --dart-define=OPENAI_API_KEY=your_key` and read it in code with `const String.fromEnvironment('OPENAI_API_KEY')`. This keeps the key out of the committed source and allows different keys for dev/prod environments​[dev.to](https://dev.to/harsh8088/flutter-best-practices-for-api-key-security-145m#:~:text=2.%20Using%20%60)​[dev.to](https://dev.to/harsh8088/flutter-best-practices-for-api-key-security-145m#:~:text=void%20main%28%29%20). (Note that these become part of the compiled binary, so they can still be found by an advanced decompiler, but it's less obvious than plain text in code.)

* **Encrypted/local configuration:** Use a protected configuration file (like a `.env` file) and a package such as `envied` to load and optionally obfuscate the values​[dev.to](https://dev.to/harsh8088/flutter-best-practices-for-api-key-security-145m#:~:text=Benefits%3A). The `.env` file (containing keys and secrets) should be listed in `.gitignore` so it’s not checked into version control​[dev.to](https://dev.to/harsh8088/flutter-best-practices-for-api-key-security-145m#:~:text=Important%3A%20Never%20commit%20the%20,file%20to%20prevent%20accidental%20exposure)​[dev.to](https://dev.to/harsh8088/flutter-best-practices-for-api-key-security-145m#:~:text=,separate%20from%20your%20application%20code). The `envied` package can generate Dart code with your keys, even applying XOR obfuscation on them at compile-time for an extra layer of defense​[dev.to](https://dev.to/harsh8088/flutter-best-practices-for-api-key-security-145m#:~:text=Benefits%3A).

* **Secure storage at runtime:** For tokens and user credentials obtained at runtime (like an OAuth2 access token or refresh token), use platform secure storage. The `flutter_secure_storage` plugin stores sensitive data in iOS Keychain or Android Keystore, protecting it with device security​[pub.dev](https://pub.dev/packages/flutter_secure_storage#:~:text=Flutter%20Secure%20Storage%20provides%20API,solution%20is%20used%20in%20Android). For example, after the OAuth2 flow, store the refresh token in secure storage rather than plain `SharedPreferences`.

* **Server-side mediation:** For highly sensitive API secrets (like OpenAI API keys or certain Google credentials), the best practice is to **not include them in the client app at all**​[reddit.com](https://www.reddit.com/r/FlutterDev/comments/jhdwq8/how_to_secure_api_keys/#:~:text=How%20to%20secure%20API%20keys%3F,your%20calls%20to%20external%20services). Instead, have your own backend service that holds the secret and communicates with the third-party API, providing results to your app. In our context, this could mean having the app make a request to your server, which then calls the OpenAI API with a secure key – so the key is never on the device. This adds complexity but greatly improves security​[reddit.com](https://www.reddit.com/r/FlutterDev/comments/jhdwq8/how_to_secure_api_keys/#:~:text=How%20to%20secure%20API%20keys%3F,your%20calls%20to%20external%20services).

* **OAuth2 best practices:** When using OAuth2 (e.g. Google Sign-In for Drive access), use the recommended flows (authorization code with PKCE for mobile) which do not require storing a client secret in the app. Rely on trusted libraries (like `google_sign_in` for Google or `flutter_appauth`) that handle the token exchange securely. Ensure the OAuth client ID and scopes are properly configured, and treat tokens like passwords – store them securely and transmit over HTTPS only.

In summary, protect all credentials by keeping them out of source code, off public repos, and in secure storage. Leverage Flutter’s build/configuration tools and secure storage APIs to manage keys. This prevents unauthorized access and abuse of your Google Drive, OpenAI, or other services with stolen keys.

## **Asynchronous Programming and Error Handling**

Working with multiple network services (Drive API calls, OpenAI requests, etc.) means embracing Dart’s asynchronous features and handling errors robustly. Use `async`/`await` for readability and to avoid callback hell when calling APIs – this makes the flow easier to follow and errors easier to catch. Always wrap asynchronous calls in try/catch blocks or use `.catchError` handlers so that exceptions (like network errors, timeouts, or JSON parsing issues) are caught and handled gracefully, rather than crashing the app. **Never let futures or streams fail silently**; unhandled async errors can terminate the app or cause odd behavior. Good error handling improves the app’s **robustness**, allowing it to gracefully handle unexpected situations (like API failures) without crashing, thus preserving a good user experience​[essannouni.medium.com](https://essannouni.medium.com/handling-errors-in-asynchronous-operations-in-flutter-665faeb885ba#:~:text=Error%20handling%20is%20a%20critical,Flutter%20applications%2C%20for%20several%20reasons). It’s also critical for **debugging** – catching errors and logging them (to console or analytics) helps diagnose issues faster​[essannouni.medium.com](https://essannouni.medium.com/handling-errors-in-asynchronous-operations-in-flutter-665faeb885ba#:~:text=2,issues%20during%20development%20and%20maintenance).

For each API integration, define clear error handling strategies. For example, if a Google Drive file download fails, catch the exception and perhaps show a message like "Failed to load content. Please check your connection." If the OpenAI API returns an error (rate limit exceeded, etc.), handle that and maybe retry or inform the user appropriately. Avoid blanket catching without action – always log the error or inform the user when an action couldn’t be completed.

Additionally, utilize Flutter’s framework for error handling:

* In the UI, you can use widgets like `FutureBuilder` or `StreamBuilder` which provide `snapshot.error` you can display if something went wrong during an async operation.

* Implement a global error handler for uncaught errors (e.g., set `FlutterError.onError` in `main()` to catch Flutter framework errors, and use `PlatformDispatcher.instance.onError` for any errors in the zone outside Flutter’s callbacks). This can capture errors that slipped through and log them (possibly sending to a service like Sentry or Firebase Crashlytics).

* Use timeouts or cancellation for async tasks when appropriate (e.g., if an OpenAI API call is taking too long, you might cancel it to free resources).

By handling errors, you **prevent data loss or corruption** – for instance, if saving data to Drive fails, you can retry or save locally until online​[essannouni.medium.com](https://essannouni.medium.com/handling-errors-in-asynchronous-operations-in-flutter-665faeb885ba#:~:text=3,informed%20if%20an%20error%20occurs). Proper error handling also has security benefits (no leaking of sensitive info via uncaught exception messages)​[essannouni.medium.com](https://essannouni.medium.com/handling-errors-in-asynchronous-operations-in-flutter-665faeb885ba#:~:text=4,preventing%20attackers%20from%20exploiting%20them) and makes maintenance easier by isolating error-handling logic. Overall, always anticipate failures (network down, API error, JSON format change, etc.) and handle them in code, ensuring the app remains stable under adverse conditions.

## **Efficient Data Storage, Caching, and Retrieval**

With features like downloading training materials from Google Drive, generating content with OpenAI, and using TTS, the app will handle significant data. Implementing **caching** and efficient storage is vital for performance and offline support. The core principle is to avoid unnecessary network calls by storing and reusing data that has already been fetched – *“just because you can load data from remote servers doesn't mean you always should”*​[docs.flutter.dev](https://docs.flutter.dev/get-started/fundamentals/local-caching#:~:text=Now%20that%20you%27ve%20learned%20about,task%20in%20your%20Flutter%20app). Re-use previously fetched data when possible, so users don’t wait again for content that hasn’t changed.

**Caching strategies:**

* **In-memory caching:** Keep recently used data in memory for quick access (e.g., cache the last loaded lesson or the user’s OpenAI conversation context). This is the fastest cache and resets when the app closes. Just be mindful of memory usage and clear caches if they grow too large or when data becomes outdated.

* **Disk caching:** For data that should persist across sessions or be available offline, use persistent storage. Small pieces of data (key-value pairs like user preferences or auth tokens) can go in `SharedPreferences`. For larger or structured data, consider a local database or file storage. For example, when a PDF or video is fetched from Google Drive, save it in the app’s documents directory so that next time it can be opened instantly. Use the **path\_provider** package to get proper file paths, and store files with a naming scheme (perhaps based on file ID or hash). You might also use a caching library like `flutter_cache_manager` which simplifies downloading and caching files to disk with expiry rules.

**Local database:** If the app has structured data (like a list of courses, user progress records, chat transcripts), use an on-device database for efficient queries. Choices include:

* **SQLite** – robust SQL database for complex relational data (via the `sqflite` plugin)​[ptolemay.com](https://www.ptolemay.com/post/making-your-flutter-app-work-offline#:~:text=1).

* **Drift (formerly Moor)** – a Flutter-friendly ORM built on SQLite that provides type safety and reactive queries​[ptolemay.com](https://www.ptolemay.com/post/making-your-flutter-app-work-offline#:~:text=3).

* **Hive** – a fast, file-based NoSQL database useful for storing JSON-like data or Dart objects with minimal friction (does not require SQL)​[ptolemay.com](https://www.ptolemay.com/post/making-your-flutter-app-work-offline#:~:text=2).

* You can also use **ObjectBox** or other local database solutions; the key is to choose one that fits the data complexity.

For simple caching of API responses or settings, **Hive** or even just JSON files might be sufficient (Hive is extremely quick for key-value and small documents). For more complex relationships or large datasets (e.g., a library of training resources with categories and metadata), **SQLite/Drift** might be more appropriate.

Make sure to implement **cache invalidation** policies. Cached data can become **stale** if the source changes​[docs.flutter.dev](https://docs.flutter.dev/get-started/fundamentals/local-caching#:~:text=). For example, if a trainer updates a file on Google Drive, the app should detect that (maybe via file timestamps or an API call) and refresh the cache. Strategies include time-based expiration (e.g., consider data stale after X hours and refetch) or version tracking (store a content version and update when it changes). *“The two hardest things in computer science are cache invalidation and naming things,”* as the saying goes, but it’s important to plan when to refresh or purge cached data​[docs.flutter.dev](https://docs.flutter.dev/get-started/fundamentals/local-caching#:~:text=A%20popular%20joke%20among%20computer,one%20errors). Perhaps provide a manual refresh option to users as well (e.g., a “Pull to refresh” that forces a new fetch, bypassing cache).

Also consider **offline mode**: using cached data to allow learners to read content without internet. Ensure the app checks for connectivity and if offline, serves last known data from cache with a notice. For any data that users modify (like quiz answers or notes) while offline, queue it and sync to Google Drive or backend when connection is restored (this requires careful sync logic but greatly enhances user experience).

Finally, secure any sensitive cached data. If you cache personal information or any sensitive content, consider encrypting it on disk (there are packages for encrypted shared preferences or you can encrypt files manually) to protect user privacy.

In summary, **store data efficiently**: use in-memory caching for instant reuse, on-disk caching for offline access, appropriate databases for structured data, and always avoid redundant network calls. This will **boost performance** (fewer loading spinners) and **reduce data usage** for users​[ptolemay.com](https://www.ptolemay.com/post/making-your-flutter-app-work-offline#:~:text=Why%20Caching%20is%20Essential%20for,Offline%20Apps), while also enabling the app to function in poor network conditions.

## **Performance Optimization**

Flutter is quite performant by default, but integrating multiple services and heavy tasks means you should follow best practices to keep the app **smooth (60fps)** and **responsive**. Here are key performance considerations:

* **Optimize widget builds:** Avoid doing expensive work in widget `build()` methods, since `build()` may be called many times (every rebuild). Layout calculations, complex state updates, or large data processing should be moved outside of `build()`. For example, do parsing or heavy computations in the `initState()` or in an async function before calling setState, rather than in the build. Flutter docs advise *“avoid repetitive and costly work in build() methods since build() can be invoked frequently when ancestor widgets rebuild.”*​[docs.flutter.dev](https://docs.flutter.dev/perf/best-practices#:~:text=Here%20are%20some%20things%20to,mind%20when%20designing%20your%20UI). If you find a widget’s build is long or complex, refactor parts of it into sub-widgets.

* **Minimize widget rebuilds:** Use Flutter’s composition to your advantage. Split large widgets into smaller widgets so that when state changes, only the affected portion rebuilds​[docs.flutter.dev](https://docs.flutter.dev/perf/best-practices#:~:text=,optimizing%20animations%20where%20the%20animation). Call `setState` as locally as possible – updating a deeply nested widget should not trigger a rebuild of the whole page if only a small area needs updating​[docs.flutter.dev](https://docs.flutter.dev/perf/best-practices#:~:text=,optimizing%20animations%20where%20the%20animation). Leverage the fact that Flutter will short-circuit rebuilding subtrees that haven’t changed: use `const` constructors for widgets that don’t depend on changing state, which tells Flutter it can reuse the widget instance without rebuilding it​[docs.flutter.dev](https://docs.flutter.dev/perf/best-practices#:~:text=,StatelessWidget%20rather%20than%20a%20function). Using `const` widgets (where possible) and `const` constructors for styles, etc., significantly reduces rebuild cost because Flutter can skip a lot of work. In fact, enabling the `flutter_lints` recommended set will remind you to mark widgets as const where applicable​[docs.flutter.dev](https://docs.flutter.dev/perf/best-practices#:~:text=but%20see%20the%20pitfalls%20section,StatelessWidget%20rather%20than%20a%20function).

* **Use efficient lists/grids:** For any scrolling list of content (e.g., a list of training resources, or chat messages), always use lazy builders (`ListView.builder`, `GridView.builder`, etc.). This ensures only the items visible on screen are built at first, and others are built on demand as you scroll​[docs.flutter.dev](https://docs.flutter.dev/perf/best-practices#:~:text=). Creating a huge list of widgets upfront (e.g., building 1000 list items at once) will cause jank and memory usage spikes. With builder delegates, you keep scrolling smooth even with large or infinite lists. Also consider using pagination or incremental loading for very large lists (loading next set of items when reaching the end).

* **Avoid unnecessary layouts:** Widgets that trigger multiple layout passes (like using **intrinsic width/height** calculations or overly nested layout builders) can hurt performance​[docs.flutter.dev](https://docs.flutter.dev/perf/best-practices#:~:text=For%20some%20widgets%2C%20particularly%20grids,and%20that%20can%20slow%20performance)​[docs.flutter.dev](https://docs.flutter.dev/perf/best-practices#:~:text=For%20example%2C%20consider%20a%20large,card%20what%20size%20to%20use). For example, using `IntrinsicHeight` or overly flexible layout in a massive grid can cause the framework to perform expensive measurement passes. Prefer fixed dimensions or constraints where possible, or simplify layout structure to avoid heavy computation. Flutter’s profiling tools can show if layout is taking too long (watch for “intrinsic” passes in the timeline).

* **Dispose of unused resources:** Be diligent in disposing controllers, text editing controllers, animation controllers, and streams in your `State.dispose()` method. Neglecting this can lead to memory leaks and even degrade performance over time (e.g., animations consuming CPU when no longer needed)​[dhiwise.com](https://www.dhiwise.com/post/mastering-resource-management-the-role-of-flutter-dispose#:~:text=1%40override%202%20void%20dispose%28%29%20,dispose%28%29%3B%205). For instance, if you start an animation or a periodic timer, always cancel or dispose it when the widget is removed. Similarly, close stream subscriptions (like listening to a Firebase stream) to free resources. This “clean-up” step keeps the app’s memory footprint stable and avoids hidden background work.

* **Throttle expensive operations:** If using OpenAI API or TTS in a rapid sequence (say user typing and you call OpenAI on every keystroke, or TTS on every small text change), introduce throttling/debouncing to limit how often these heavy operations run. This prevents overwhelming the device (and the external API). Perform bulk operations off the UI thread if possible – e.g., if you have to do a large JSON processing or audio processing, consider using `compute()` or spawning an Isolate to do it in the background, keeping the UI thread free.

* **Frame budgeting:** Aim to keep any UI thread operation under 16 milliseconds (for 60fps). Use the **Flutter DevTools Performance** view to profile jank – it will show frames that missed the 16ms target. If animations or navigations stutter, profile to find the slow frame and optimize the code in that frame (maybe a large image decode or layout that could be optimized or deferred).

* **Asset optimization:** Optimize your assets and resources as well. Large images or video files should be properly compressed. Use appropriate image formats (WebP for smaller size if supported, etc.). If you display images from Drive, consider caching and resizing them to the needed resolution rather than loading full high-res every time. This not only improves performance but also memory usage.

* **Test on real devices:** Performance can vary on different hardware. Test on a range of devices (low-end Android, high-end iPhone, etc.) to ensure the app runs smoothly everywhere. Adjustments like using less computationally intensive animations or reducing effect overhead might be needed for lower-end phones.

In essence, follow Flutter’s general performance advice: **reduce rebuilds, drop unnecessary work, and use tools to find bottlenecks**​[bacancytechnology.com](https://www.bacancytechnology.com/blog/flutter-performance#:~:text=Developers%20can%20use%20a%20suite,down%20the%20Flutter%20app%20performance). Keep the app responsive by not blocking the UI thread (do async work asynchronously), and keep the GPU pipeline clear by avoiding heavy layering (e.g., use `Opacity` widget sparingly as it triggers offscreen compositing which is expensive). With these practices, even with integration of multiple services, your app should remain fast and fluid.

## **Accessibility and Localization**

Building the app with **accessibility** and **localization** in mind will make it usable to a wider audience and in different regions.

**Accessibility:** Ensure the app’s features (especially text content and interactive lessons) are available to users with disabilities. Flutter provides built-in support for things like screen readers, large fonts, and high contrast​[docs.flutter.dev](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility#:~:text=Large%20fonts%20%20Render%20text,colors%20that%20have%20sufficient%20contrast). Leverage these:

* **Screen reader support:** All interactive widgets (buttons, list items, icons that act as buttons) should have a readable label. If you use standard widgets with text (like `ElevatedButton` with a Text child), you’re covered. But if you have custom widgets or just an icon that needs context, wrap it with a `Semantics` widget or provide a `semanticLabel`. For example, an icon button might be given `Tooltip` or `IconButton`’s `label` for screen readers. This ensures TalkBack (Android) or VoiceOver (iOS) will announce what the control is. The OpenAI chatbot feature, for instance, should announce messages and allow focus on them.

* **Large font and screen scaling:** Flutter text widgets respond to the device’s font scaling by default (if `MediaQuery.textScaleFactor` is \>1). Make sure your UI doesn’t break with larger text – test by increasing font size in accessibility settings. Avoid hard-coding font sizes too small; use relative sizes or ensure content containers can scroll if text is large. Flutter’s accessibility guidelines ensure text can be scaled at least 200%​[docs.flutter.dev](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility#:~:text=%2F%2F%20Checks%20that%20tappable%20nodes,await%20expectLater%28tester%2C%20meetsGuideline%28androidTapTargetGuideline)​[docs.flutter.dev](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility#:~:text=%2F%2F%20Checks%20whether%20semantic%20nodes,). Use `Flexible`/`Expanded` widgets to allow layouts to adjust, and consider using the `MediaQuery` to adapt layout for very large text (maybe switch to a single-column view if content was side-by-side).

* **Contrast and colors:** Use sufficient contrast for text and important UI elements. The Material Design baseline ensures a minimum contrast, but if you customize colors, check them. There are online contrast checkers and the Flutter accessibility guideline API (in tests) can check text contrast meets guidelines​[docs.flutter.dev](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility#:~:text=%2F%2F%20Checks%20that%20tappable%20nodes,await%20expectLater%28tester%2C%20meetsGuideline%28iOSTapTargetGuideline). For any text on a colored background, aim for a contrast ratio of at least 4.5:1 for normal text (3:1 for large text).

* **Navigation and focus:** Ensure that all interactive elements can be accessed via keyboard traversal (especially important if the app were to run on web or desktop, or for users with external keyboards). Flutter’s focus traversal is automatic in most cases, but custom widgets might need a `FocusNode`. Also, if any dynamic content appears (dialogs, popups), make sure screen readers are alerted (Flutter’s dialogs handle this).

* **TTS usage:** The app includes Text-to-Speech, which can be a boon for accessibility. Provide a clear toggle or button for users to have content read aloud. Ensure that using TTS doesn’t interfere with screen readers (for example, if a visually impaired user is already using VoiceOver, they might not need the app’s TTS, so avoid double-speaking). TTS can be more of a learning feature, but it overlaps with accessibility.

Test accessibility with real tools: use Android’s Accessibility Scanner and talkback, and iOS Accessibility Inspector, to audit your app​[docs.flutter.dev](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility#:~:text=). Address any issues those tools flag (like touch targets too small – ensure buttons are at least 48x48 dp in size, which the guideline tests can verify​[docs.flutter.dev](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility#:~:text=%2F%2F%20Checks%20that%20tappable%20nodes,await%20expectLater%28tester%2C%20meetsGuideline%28androidTapTargetGuideline)).

**Localization:** Prepare the app to support multiple languages and locales:

* **Externalize all strings** that appear in the UI. Instead of hardcoding English text in widgets, use the Flutter internationalization tools. Typically, you would use ARB files (Application Resource Bundle JSON files) to store translations for each language, and the Flutter localization codegen will generate a `AppLocalizations` class for you. For example, have an `app_en.arb` for English and `app_es.arb` for Spanish, etc., containing key-value pairs of translatable strings​[phrase.com](https://phrase.com/blog/posts/flutter-localization/#:~:text=Flutter%20localization%20uses%20ARB%20,template%20translations%20file%20to%20it).

* **Configure localization support:** Include `flutter_localizations` in your pubspec and specify supported locales in your `MaterialApp` (the `supportedLocales` list and a `localizationsDelegates` including `AppLocalizations.delegate`)​[phrase.com](https://phrase.com/blog/posts/flutter-localization/#:~:text=,0.18.0)​[phrase.com](https://phrase.com/blog/posts/flutter-localization/#:~:text=flutter%3A%20generate%3A%C2%A0true%20,design%3A%C2%A0true%20Code%20language%3A%20YAML%20%28yaml). This will load the appropriate strings based on the device’s locale.

* **Plural and gender considerations:** If your app shows dynamic text (like "$n$ files downloaded"), use the ICU message format in ARB files to handle pluralization properly instead of manual if/else in code. The Dart `intl` library will handle pluralization, gender, etc., as long as your ARB entries are set up (e.g., `"filesDownloaded": "{num, plural, one{1 file downloaded} other{{num} files downloaded}}"`).

* **Locale-specific formatting:** Utilize the intl package for dates, numbers, and currencies. For instance, if the app shows a date (maybe last updated date on a file), use `DateFormat.yMMMd(locale)` instead of a fixed format, so that in different locales it displays appropriately.

* **Right-to-left (RTL) support:** Arabic or Hebrew text (if your app is used in those languages) will automatically render RTL when the locale is set (Flutter handles layout mirroring for you if `MaterialApp.supportedLocales` includes an RTL locale). Test that screens still look correct in RTL – e.g., padding might need flipping, but Flutter does this for standard widgets. Ensure any custom layout isn’t biased to LTR only.

* **Testing:** Emulate different locales (you can do `flutter run --locale=es` for Spanish, or change your device language) to test the UI. Also test that when switching language (if you provide an in-app language switcher or just relying on device setting), the content updates.

By internationalizing the app, you make it easy to add new languages for different markets without code changes – just new ARB files or translation entries. This could be very relevant if the training app needs to be used by learners in different countries.

In summary, **bake in accessibility and localization from the start**. This means designing UI and writing code that is flexible for screen readers and translations. It’s much harder to retrofit these later. An accessible, localized app will reach more users and provide a better experience for everyone, whether it’s a trainer with low vision who needs TTS or a learner who speaks a different language.

## **Testing and Debugging Tools**

A robust Flutter project requires a strong testing strategy and effective debugging techniques. Invest time in **automated testing** to catch issues early, and use Flutter’s dev tools to debug runtime problems.

**Automated Testing:** Aim to cover your code with unit, widget, and integration tests:

* **Unit tests** for all your Dart logic (e.g., functions that process data, format text, or any service classes that call APIs). For example, test the Drive API integration methods with fake responses to ensure JSON parsing is correct, or test that your OpenAI response handler properly formats the AI reply. Unit tests are fast and should form the bulk of your test suite.

* **Widget tests** for individual UI components. You can pump a widget (like a specific screen or even a custom widget) in a test environment and verify it displays expected text or has certain behaviors when interacted with. For instance, test that the Trainer’s content upload form shows validation errors when fields are empty, or that tapping the “play TTS” button invokes the TTS functionality (maybe use a mock method). Widget tests ensure UI logic works without running a full app. They are slower than unit tests but still reasonably quick.

* **Integration tests** for full end-to-end scenarios: these run the actual app on a device/emulator and simulate user actions. Write integration tests for critical flows like **“Trainer login \-\> upload content \-\> Learner login \-\> access that content \-\> play TTS \-\> ask question to AI”** to ensure everything works together. Integration tests give the highest confidence as they involve real UI and service calls (you might use fake servers or test accounts for this). Use Flutter’s `integration_test` package or `flutter_driver` to script these interactions.

A **well-tested app** typically has many unit and widget tests, plus enough integration tests to cover all major use cases​[docs.flutter.dev](https://docs.flutter.dev/testing/overview#:~:text=Generally%20speaking%2C%20a%20well,kinds%20of%20testing%2C%20seen%20below). This layered testing approach balances confidence and maintenance cost. Track your test coverage and try to cover core logic (especially security-critical code like OAuth flows or complex logic like caching rules).

Also consider test cases for edge conditions: no internet (does the app gracefully show offline mode?), API errors (does a 500 error from OpenAI show an error message?), etc. Use mocking (with packages like `mockito`) to simulate these in tests.

**Debugging Tools:** During development and for troubleshooting issues, use Flutter’s rich debugging arsenal:

* **Flutter DevTools:** This is a suite of tools that runs in a browser or IDE. The **Widget Inspector** helps debug layout issues by letting you select widgets on the device and see their properties. This is great for UI alignment, padding, and understanding the widget tree in complex UIs. The **Performance** tab in DevTools allows you to record frames and analyze rendering times; use this to pinpoint performance bottlenecks if you notice jank (as discussed earlier)​[bacancytechnology.com](https://www.bacancytechnology.com/blog/flutter-performance#:~:text=Developers%20can%20use%20a%20suite,down%20the%20Flutter%20app%20performance). The **Memory** tab shows memory usage and can help detect memory leaks (if memory keeps growing, you might have forgotten to dispose something). There’s also a **Network** tab (for Flutter web or add-ons) and **Logging** view to see application logs.

* **Logging and error tracking:** Utilize `debugPrint` or Logger packages to output useful debug information in development. For example, log the response from OpenAI or the steps in the OAuth flow when debugging issues. Be careful not to log sensitive data in production logs. Use conditional logging (perhaps enabled via a debug flag). For catching errors in the wild, integrate a service like **Firebase Crashlytics** or **Sentry**. These can automatically capture uncaught exceptions and provide stack traces for crashes or important errors, greatly simplifying post-release debugging. Set up Crashlytics early so you have insight if a user encounters an error that wasn’t caught in testing.

* **Hot Reload/Hot Restart:** Use hot reload during development for quick UI iteration, but know when to do a full restart (certain changes like switching locales or initializing certain singletons might need a restart). Hot reload is a huge productivity boon when tweaking UI or logic – take advantage of it to test small changes rapidly.

* **Stateful Debugging:** Dart/Flutter allows attaching the debugger to set breakpoints, step through code, and inspect variables. Use breakpoints in Android Studio/VS Code to pause execution when certain conditions are met (e.g., set a breakpoint in the error callback of an API call to inspect the error object). You can also use conditional breakpoints (break only if a certain user ID is encountered, etc.). Stepping through asynchronous code can be tricky, but Dart does maintain the stack traces pretty well.

* **Dev/Test mode flags:** You might include a debug menu or special commands in debug builds (not in release) to aid testing. For instance, a debug mode where you can reset the app, or populate test data, or switch user roles quickly. This isn’t a tool per se, but a strategy to make manual testing easier.

**Continuous Integration (CI):** It’s a good practice to automate running your test suite on a CI service (GitHub Actions, GitLab CI, etc.) whenever code is pushed. This ensures that new changes don’t break existing functionality. For a Flutter project, set up the CI to run `flutter analyze` (static code analysis for linting issues), `flutter test` (unit/widget tests), and possibly integration tests on Firebase Test Lab or emulators. This way, you catch problems early and maintain code health.

By writing thorough tests and using debugging tools proactively, you can maintain a high-quality app. Testing catches regressions and ensures new features (like adding a new role capability or a new API integration) don’t break others. And when bugs do appear in production, your logging and crash reports combined with the ability to reproduce issues with DevTools will help you squash them quickly. A disciplined approach to testing and debugging ultimately leads to a more reliable and trust-worthy application.
