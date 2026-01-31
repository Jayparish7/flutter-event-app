// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Studios`
  String get studio {
    return Intl.message(
      'Studios',
      name: 'studio',
      desc: '',
      args: [],
    );
  }

  /// `Events`
  String get events {
    return Intl.message(
      'Events',
      name: 'events',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `uploading`
  String get uploading {
    return Intl.message(
      'uploading',
      name: 'uploading',
      desc: '',
      args: [],
    );
  }

  /// `uploaded`
  String get uploaded {
    return Intl.message(
      'uploaded',
      name: 'uploaded',
      desc: '',
      args: [],
    );
  }

  /// `Recent Uploads`
  String get recent_upload {
    return Intl.message(
      'Recent Uploads',
      name: 'recent_upload',
      desc: '',
      args: [],
    );
  }

  /// `No Recent Uploads`
  String get no_recent_upload {
    return Intl.message(
      'No Recent Uploads',
      name: 'no_recent_upload',
      desc: '',
      args: [],
    );
  }

  /// `Upload Completed`
  String get upload_completed {
    return Intl.message(
      'Upload Completed',
      name: 'upload_completed',
      desc: '',
      args: [],
    );
  }

  /// `Update !`
  String get update {
    return Intl.message(
      'Update !',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Later`
  String get later {
    return Intl.message(
      'Later',
      name: 'later',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Add Event`
  String get add_event {
    return Intl.message(
      'Add Event',
      name: 'add_event',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `To add an Event\n click on the Add Event Button`
  String get no_events {
    return Intl.message(
      'To add an Event\n click on the Add Event Button',
      name: 'no_events',
      desc: '',
      args: [],
    );
  }

  /// `Pick folder`
  String get pick_folder {
    return Intl.message(
      'Pick folder',
      name: 'pick_folder',
      desc: '',
      args: [],
    );
  }

  /// `Choose the original folder to get the selected photos`
  String get choose_the_original_folder {
    return Intl.message(
      'Choose the original folder to get the selected photos',
      name: 'choose_the_original_folder',
      desc: '',
      args: [],
    );
  }

  /// `Select Folder`
  String get select_folder {
    return Intl.message(
      'Select Folder',
      name: 'select_folder',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Go to Sub Folder`
  String get go_to_sub_folder {
    return Intl.message(
      'Go to Sub Folder',
      name: 'go_to_sub_folder',
      desc: '',
      args: [],
    );
  }

  /// `Pick Original Folder`
  String get pick_original_folder {
    return Intl.message(
      'Pick Original Folder',
      name: 'pick_original_folder',
      desc: '',
      args: [],
    );
  }

  /// `Pick the original Path for this folder where the original photos exists`
  String get Pick_Path_original_photos_exists {
    return Intl.message(
      'Pick the original Path for this folder where the original photos exists',
      name: 'Pick_Path_original_photos_exists',
      desc: '',
      args: [],
    );
  }

  /// `Pick`
  String get Pick {
    return Intl.message(
      'Pick',
      name: 'Pick',
      desc: '',
      args: [],
    );
  }

  /// `Segregation format`
  String get segregation_format {
    return Intl.message(
      'Segregation format',
      name: 'segregation_format',
      desc: '',
      args: [],
    );
  }

  /// `Format:`
  String get format {
    return Intl.message(
      'Format:',
      name: 'format',
      desc: '',
      args: [],
    );
  }

  /// `Select an format:`
  String get select_an_format {
    return Intl.message(
      'Select an format:',
      name: 'select_an_format',
      desc: '',
      args: [],
    );
  }

  /// `Segregation Path`
  String get segregation_path {
    return Intl.message(
      'Segregation Path',
      name: 'segregation_path',
      desc: '',
      args: [],
    );
  }

  /// `Number of images`
  String get number_of_images {
    return Intl.message(
      'Number of images',
      name: 'number_of_images',
      desc: '',
      args: [],
    );
  }

  /// `Number of Folders`
  String get number_of_folders {
    return Intl.message(
      'Number of Folders',
      name: 'number_of_folders',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `Photo Selection`
  String get photoSelection {
    return Intl.message(
      'Photo Selection',
      name: 'photoSelection',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation status`
  String get confirmation_status {
    return Intl.message(
      'Confirmation status',
      name: 'confirmation_status',
      desc: '',
      args: [],
    );
  }

  /// `Not Submitted`
  String get not_submitted {
    return Intl.message(
      'Not Submitted',
      name: 'not_submitted',
      desc: '',
      args: [],
    );
  }

  /// `Submitted`
  String get submitted {
    return Intl.message(
      'Submitted',
      name: 'submitted',
      desc: '',
      args: [],
    );
  }

  /// `Total number of Albums`
  String get total_number_of_albums {
    return Intl.message(
      'Total number of Albums',
      name: 'total_number_of_albums',
      desc: '',
      args: [],
    );
  }

  /// `Add Album`
  String get add_album {
    return Intl.message(
      'Add Album',
      name: 'add_album',
      desc: '',
      args: [],
    );
  }

  /// `Album name`
  String get album_name {
    return Intl.message(
      'Album name',
      name: 'album_name',
      desc: '',
      args: [],
    );
  }

  /// `Please select a folder`
  String get please_pick_a_folder {
    return Intl.message(
      'Please select a folder',
      name: 'please_pick_a_folder',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `please pick path and enter file name`
  String get please_pick_path_and_enter_file_name {
    return Intl.message(
      'please pick path and enter file name',
      name: 'please_pick_path_and_enter_file_name',
      desc: '',
      args: [],
    );
  }

  /// `Device Changed`
  String get device_changed {
    return Intl.message(
      'Device Changed',
      name: 'device_changed',
      desc: '',
      args: [],
    );
  }

  /// `Path not exist try another device`
  String get path_not_exists {
    return Intl.message(
      'Path not exist try another device',
      name: 'path_not_exists',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message(
      'Dashboard',
      name: 'dashboard',
      desc: '',
      args: [],
    );
  }

  /// `Website`
  String get website {
    return Intl.message(
      'Website',
      name: 'website',
      desc: '',
      args: [],
    );
  }

  /// `android-app`
  String get android_app {
    return Intl.message(
      'android-app',
      name: 'android_app',
      desc: '',
      args: [],
    );
  }

  /// `Copy Link`
  String get copy_link {
    return Intl.message(
      'Copy Link',
      name: 'copy_link',
      desc: '',
      args: [],
    );
  }

  /// `Open in Browser`
  String get open_in_browser {
    return Intl.message(
      'Open in Browser',
      name: 'open_in_browser',
      desc: '',
      args: [],
    );
  }

  /// `Download QR Code`
  String get download_qr_code {
    return Intl.message(
      'Download QR Code',
      name: 'download_qr_code',
      desc: '',
      args: [],
    );
  }

  /// `Android Application`
  String get android_application {
    return Intl.message(
      'Android Application',
      name: 'android_application',
      desc: '',
      args: [],
    );
  }

  /// `Choose Height x Width`
  String get choose_height_width {
    return Intl.message(
      'Choose Height x Width',
      name: 'choose_height_width',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Reviews`
  String get reviews {
    return Intl.message(
      'Reviews',
      name: 'reviews',
      desc: '',
      args: [],
    );
  }

  /// `No Reviews Found`
  String get no_review_found {
    return Intl.message(
      'No Reviews Found',
      name: 'no_review_found',
      desc: '',
      args: [],
    );
  }

  /// `No Packages Found`
  String get no_package_found {
    return Intl.message(
      'No Packages Found',
      name: 'no_package_found',
      desc: '',
      args: [],
    );
  }

  /// `Packages`
  String get packages {
    return Intl.message(
      'Packages',
      name: 'packages',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message(
      'Price',
      name: 'price',
      desc: '',
      args: [],
    );
  }

  /// `Discount`
  String get discount {
    return Intl.message(
      'Discount',
      name: 'discount',
      desc: '',
      args: [],
    );
  }

  /// `Priority Score`
  String get priority_score {
    return Intl.message(
      'Priority Score',
      name: 'priority_score',
      desc: '',
      args: [],
    );
  }

  /// `Published`
  String get published {
    return Intl.message(
      'Published',
      name: 'published',
      desc: '',
      args: [],
    );
  }

  /// `unPublished`
  String get unPublished {
    return Intl.message(
      'unPublished',
      name: 'unPublished',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Event key`
  String get event_key {
    return Intl.message(
      'Event key',
      name: 'event_key',
      desc: '',
      args: [],
    );
  }

  /// `Event Link`
  String get event_link {
    return Intl.message(
      'Event Link',
      name: 'event_link',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number or email`
  String get please_enter_a_valid_phone_number_or_email {
    return Intl.message(
      'Please enter a valid phone number or email',
      name: 'please_enter_a_valid_phone_number_or_email',
      desc: '',
      args: [],
    );
  }

  /// `Use your mobile number or email Address`
  String get use_your_mobile_number_or_email_address {
    return Intl.message(
      'Use your mobile number or email Address',
      name: 'use_your_mobile_number_or_email_address',
      desc: '',
      args: [],
    );
  }

  /// `Phone / Email address`
  String get phone_email_address {
    return Intl.message(
      'Phone / Email address',
      name: 'phone_email_address',
      desc: '',
      args: [],
    );
  }

  /// `Empty`
  String get empty {
    return Intl.message(
      'Empty',
      name: 'empty',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your phone/email`
  String get please_enter_your_phone_email {
    return Intl.message(
      'Please enter your phone/email',
      name: 'please_enter_your_phone_email',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `OTP`
  String get otp {
    return Intl.message(
      'OTP',
      name: 'otp',
      desc: '',
      args: [],
    );
  }

  /// `Resend OTP`
  String get resend_otp {
    return Intl.message(
      'Resend OTP',
      name: 'resend_otp',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the OTP sent to`
  String get please_enter_the_OTP_send_to {
    return Intl.message(
      'Please enter the OTP sent to',
      name: 'please_enter_the_OTP_send_to',
      desc: '',
      args: [],
    );
  }

  /// `Please fill this field`
  String get please_fill_this_field {
    return Intl.message(
      'Please fill this field',
      name: 'please_fill_this_field',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Languages`
  String get languages {
    return Intl.message(
      'Languages',
      name: 'languages',
      desc: '',
      args: [],
    );
  }

  /// `App Language`
  String get choose_an_languages {
    return Intl.message(
      'App Language',
      name: 'choose_an_languages',
      desc: '',
      args: [],
    );
  }

  /// `Press back again to exit`
  String get press_back_again_to_exit {
    return Intl.message(
      'Press back again to exit',
      name: 'press_back_again_to_exit',
      desc: '',
      args: [],
    );
  }

  /// `Inbox`
  String get inbox {
    return Intl.message(
      'Inbox',
      name: 'inbox',
      desc: '',
      args: [],
    );
  }

  /// `Photo selection for`
  String get photoSelectionFor {
    return Intl.message(
      'Photo selection for',
      name: 'photoSelectionFor',
      desc: '',
      args: [],
    );
  }

  /// `event has been confirmed by the event owner`
  String get eventHasBeenConfirmed {
    return Intl.message(
      'event has been confirmed by the event owner',
      name: 'eventHasBeenConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Total number of images`
  String get total_number_of_images {
    return Intl.message(
      'Total number of images',
      name: 'total_number_of_images',
      desc: '',
      args: [],
    );
  }

  /// `Selected images`
  String get selected_images {
    return Intl.message(
      'Selected images',
      name: 'selected_images',
      desc: '',
      args: [],
    );
  }

  /// `Rejected images`
  String get rejected_images {
    return Intl.message(
      'Rejected images',
      name: 'rejected_images',
      desc: '',
      args: [],
    );
  }

  /// `Undecided images`
  String get undecided_images {
    return Intl.message(
      'Undecided images',
      name: 'undecided_images',
      desc: '',
      args: [],
    );
  }

  /// `Reverse Confirmation`
  String get reverse_confirmation {
    return Intl.message(
      'Reverse Confirmation',
      name: 'reverse_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Get all your Photomall updates in one place — including customer photo selection status, expiry alerts, and more`
  String get all_messages_from_photomall {
    return Intl.message(
      'Get all your Photomall updates in one place — including customer photo selection status, expiry alerts, and more',
      name: 'all_messages_from_photomall',
      desc: '',
      args: [],
    );
  }

  /// `Studio Settings`
  String get studio_settings {
    return Intl.message(
      'Studio Settings',
      name: 'studio_settings',
      desc: '',
      args: [],
    );
  }

  /// `Studio Name`
  String get studio_name {
    return Intl.message(
      'Studio Name',
      name: 'studio_name',
      desc: '',
      args: [],
    );
  }

  /// `Studio Established`
  String get studio_established {
    return Intl.message(
      'Studio Established',
      name: 'studio_established',
      desc: '',
      args: [],
    );
  }

  /// `Photo Selection Download Status`
  String get photo_selection_download_status {
    return Intl.message(
      'Photo Selection Download Status',
      name: 'photo_selection_download_status',
      desc: '',
      args: [],
    );
  }

  /// `Download With Icon`
  String get download_with_icon {
    return Intl.message(
      'Download With Icon',
      name: 'download_with_icon',
      desc: '',
      args: [],
    );
  }

  /// `ON`
  String get on {
    return Intl.message(
      'ON',
      name: 'on',
      desc: '',
      args: [],
    );
  }

  /// `OFF`
  String get off {
    return Intl.message(
      'OFF',
      name: 'off',
      desc: '',
      args: [],
    );
  }

  /// `Download with Watermark`
  String get download_with_watermark {
    return Intl.message(
      'Download with Watermark',
      name: 'download_with_watermark',
      desc: '',
      args: [],
    );
  }

  /// `My Photos Download Status`
  String get my_photos_downloadable {
    return Intl.message(
      'My Photos Download Status',
      name: 'my_photos_downloadable',
      desc: '',
      args: [],
    );
  }

  /// `Hide Media for AI Event`
  String get hide_media_photos {
    return Intl.message(
      'Hide Media for AI Event',
      name: 'hide_media_photos',
      desc: '',
      args: [],
    );
  }

  /// `Photos Print Status`
  String get photos_print_status {
    return Intl.message(
      'Photos Print Status',
      name: 'photos_print_status',
      desc: '',
      args: [],
    );
  }

  /// `Android App Redirection`
  String get forbidden_app_redirect {
    return Intl.message(
      'Android App Redirection',
      name: 'forbidden_app_redirect',
      desc: '',
      args: [],
    );
  }

  /// `App Tour`
  String get app_tour {
    return Intl.message(
      'App Tour',
      name: 'app_tour',
      desc: '',
      args: [],
    );
  }

  /// `Show Photos as Rounded Edge`
  String get show_photos_as_rounded_edge {
    return Intl.message(
      'Show Photos as Rounded Edge',
      name: 'show_photos_as_rounded_edge',
      desc: '',
      args: [],
    );
  }

  /// `Multiple People's Face per Account`
  String get users_allowed_per_account_in_face_recognition {
    return Intl.message(
      'Multiple People\'s Face per Account',
      name: 'users_allowed_per_account_in_face_recognition',
      desc: '',
      args: [],
    );
  }

  /// `Doubt Image Clear Option for User`
  String get doubt_image_clear_for_end_user {
    return Intl.message(
      'Doubt Image Clear Option for User',
      name: 'doubt_image_clear_for_end_user',
      desc: '',
      args: [],
    );
  }

  /// `Studio's Cover Image`
  String get studio_cover_image {
    return Intl.message(
      'Studio\'s Cover Image',
      name: 'studio_cover_image',
      desc: '',
      args: [],
    );
  }

  /// `Event Cover Image`
  String get event_cover_image {
    return Intl.message(
      'Event Cover Image',
      name: 'event_cover_image',
      desc: '',
      args: [],
    );
  }

  /// `Set Studio's Cover Image`
  String get set_studio_cover_image {
    return Intl.message(
      'Set Studio\'s Cover Image',
      name: 'set_studio_cover_image',
      desc: '',
      args: [],
    );
  }

  /// `Upload Default Event Cover Image`
  String get set_event_cover_image {
    return Intl.message(
      'Upload Default Event Cover Image',
      name: 'set_event_cover_image',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Change Studio Name`
  String get change_studio_name {
    return Intl.message(
      'Change Studio Name',
      name: 'change_studio_name',
      desc: '',
      args: [],
    );
  }

  /// `Users`
  String get users {
    return Intl.message(
      'Users',
      name: 'users',
      desc: '',
      args: [],
    );
  }

  /// `Events with Photo Selection`
  String get event_with_ps {
    return Intl.message(
      'Events with Photo Selection',
      name: 'event_with_ps',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed Photo Selections`
  String get confirmed_photo_selections {
    return Intl.message(
      'Confirmed Photo Selections',
      name: 'confirmed_photo_selections',
      desc: '',
      args: [],
    );
  }

  /// `Unconfirmed Photo Selections`
  String get unconfirmed_photo_selections {
    return Intl.message(
      'Unconfirmed Photo Selections',
      name: 'unconfirmed_photo_selections',
      desc: '',
      args: [],
    );
  }

  /// `Events with e-Album`
  String get event_with_EAlbum {
    return Intl.message(
      'Events with e-Album',
      name: 'event_with_EAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Events with Photos`
  String get event_with_photos {
    return Intl.message(
      'Events with Photos',
      name: 'event_with_photos',
      desc: '',
      args: [],
    );
  }

  /// `Events with Videos`
  String get event_with_videos {
    return Intl.message(
      'Events with Videos',
      name: 'event_with_videos',
      desc: '',
      args: [],
    );
  }

  /// `Add Photo Selection`
  String get add_photo_selection {
    return Intl.message(
      'Add Photo Selection',
      name: 'add_photo_selection',
      desc: '',
      args: [],
    );
  }

  /// `All studio events will use this image as the cover.`
  String get add_event_cover_image_text {
    return Intl.message(
      'All studio events will use this image as the cover.',
      name: 'add_event_cover_image_text',
      desc: '',
      args: [],
    );
  }

  /// `Media`
  String get media {
    return Intl.message(
      'Media',
      name: 'media',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Photo Selection`
  String get photo_selection {
    return Intl.message(
      'Photo Selection',
      name: 'photo_selection',
      desc: '',
      args: [],
    );
  }

  /// `Event Settings`
  String get event_settings {
    return Intl.message(
      'Event Settings',
      name: 'event_settings',
      desc: '',
      args: [],
    );
  }

  /// `No Media Available`
  String get no_media {
    return Intl.message(
      'No Media Available',
      name: 'no_media',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get are_you_sure_you_want_to_log_out {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'are_you_sure_you_want_to_log_out',
      desc: '',
      args: [],
    );
  }

  /// `Image Files Path`
  String get images_path {
    return Intl.message(
      'Image Files Path',
      name: 'images_path',
      desc: '',
      args: [],
    );
  }

  /// `Select Destination Folder`
  String get select_destination_folder {
    return Intl.message(
      'Select Destination Folder',
      name: 'select_destination_folder',
      desc: '',
      args: [],
    );
  }

  /// `Choose a Destination Folder for Moving the Selected Images`
  String get choose_destination_folder {
    return Intl.message(
      'Choose a Destination Folder for Moving the Selected Images',
      name: 'choose_destination_folder',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message(
      'Register',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Add folder`
  String get add_folder {
    return Intl.message(
      'Add folder',
      name: 'add_folder',
      desc: '',
      args: [],
    );
  }

  /// `Create Event`
  String get createEvent {
    return Intl.message(
      'Create Event',
      name: 'createEvent',
      desc: '',
      args: [],
    );
  }

  /// `User Name`
  String get userName {
    return Intl.message(
      'User Name',
      name: 'userName',
      desc: '',
      args: [],
    );
  }

  /// `Select user Name`
  String get selectUserName {
    return Intl.message(
      'Select user Name',
      name: 'selectUserName',
      desc: '',
      args: [],
    );
  }

  /// `Event Plan`
  String get eventPlan {
    return Intl.message(
      'Event Plan',
      name: 'eventPlan',
      desc: '',
      args: [],
    );
  }

  /// `select event Plan`
  String get selectEventPlan {
    return Intl.message(
      'select event Plan',
      name: 'selectEventPlan',
      desc: '',
      args: [],
    );
  }

  /// `Event category`
  String get eventCategory {
    return Intl.message(
      'Event category',
      name: 'eventCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select event category`
  String get selectEventCategory {
    return Intl.message(
      'Select event category',
      name: 'selectEventCategory',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Add New Event Category`
  String get addNewCategory {
    return Intl.message(
      'Add New Event Category',
      name: 'addNewCategory',
      desc: '',
      args: [],
    );
  }

  /// `Event Name`
  String get eventName {
    return Intl.message(
      'Event Name',
      name: 'eventName',
      desc: '',
      args: [],
    );
  }

  /// `Add User`
  String get addUser {
    return Intl.message(
      'Add User',
      name: 'addUser',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'bn'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'gu'),
      Locale.fromSubtags(languageCode: 'hi'),
      Locale.fromSubtags(languageCode: 'kn'),
      Locale.fromSubtags(languageCode: 'ml'),
      Locale.fromSubtags(languageCode: 'mr'),
      Locale.fromSubtags(languageCode: 'ms'),
      Locale.fromSubtags(languageCode: 'ta'),
      Locale.fromSubtags(languageCode: 'te'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
