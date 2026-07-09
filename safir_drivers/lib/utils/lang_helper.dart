import 'package:flutter/material.dart';

String tr(BuildContext context, String key) {
  String lang = Localizations.localeOf(context).languageCode;

  final Map<String, Map<String, String>> words = {
    // --- عمومی و منوها ---
    'app_name': {'fa': 'سفیر', 'ps': 'سفیر', 'en': 'Safir'},
    'home': {'fa': 'صفحه اصلی', 'ps': 'اصلي صفحه', 'en': 'Home'},
    'settings': {'fa': 'تنظیمات', 'ps': 'تنظیمات', 'en': 'Settings'},
    'profile': {'fa': 'پروفایل', 'ps': 'پروفایل', 'en': 'Profile'},
    'support': {'fa': 'پشتیبانی', 'ps': 'ملاتړ', 'en': 'Support'},
    'exit': {'fa': 'خروج', 'ps': 'وتل', 'en': 'Logout'},
    'confirm': {'fa': 'تایید', 'ps': 'تایید', 'en': 'Confirm'},
    'cancel': {'fa': 'لغو', 'ps': 'لغوه', 'en': 'Cancel'},
    'next_step': {'fa': 'تایید و ادامه', 'ps': 'تایید او دوام', 'en': 'Confirm & Continue'},
    'error_occurred': {'fa': 'خطایی رخ داده است', 'ps': 'تیروتنه رامنځته شوه', 'en': 'An error occurred'},
    'please_wait': {'fa': 'لطفاً منتظر بمانید...', 'ps': 'مهرباني وکړئ انتظار وکړئ...', 'en': 'Please wait...'},
    'no_data_found': {'fa': 'اطلاعاتی یافت نشد.', 'ps': 'معلومات ونه موندل شول.', 'en': 'No data found.'},
    'not_registered': {'fa': 'ثبت نشده', 'ps': 'نه دی ثبت شوی', 'en': 'Not Registered'},
    'edit': {'fa': 'ویرایش', 'ps': 'تغیرول', 'en': 'Edit'},
    'delete': {'fa': 'حذف', 'ps': 'حذف کول', 'en': 'Delete'},
    'status': {'fa': 'وضعیت', 'ps': 'حالت', 'en': 'Status'},
    'actions': {'fa': 'عملیات', 'ps': 'عملیات', 'en': 'Actions'},
    'close': {'fa': 'بستن', 'ps': 'بندول', 'en': 'Close'},

    // --- بخش مسافر و سفر ---
    'welcome_passenger': {'fa': 'به سفیر خوش آمدید', 'ps': 'سفیر ته ښه راغلاست', 'en': 'Welcome to Safir'},
    'where_to': {'fa': 'کجا می‌روید؟', 'ps': 'چیرته ځئ؟', 'en': 'Where to?'},
    'search': {'fa': 'جستجو', 'ps': 'پلټنه', 'en': 'Search'},
    'request_ride': {'fa': 'درخواست سفر', 'ps': 'د سفر غوښتنه', 'en': 'Request Ride'},
    'finding_driver': {'fa': 'در حال جستجوی سفیر...', 'ps': 'د سفیر لټون...', 'en': 'Finding Safir...'},
    'fare': {'fa': 'کرایه', 'ps': 'کرایه', 'en': 'Fare'},
    'afn': {'fa': 'افغانی', 'ps': 'افغانۍ', 'en': 'AFN'},
    'origin': {'fa': 'مبدأ', 'ps': 'مبدا', 'en': 'Origin'},
    'destination': {'fa': 'مقصد', 'ps': 'مقصد', 'en': 'Destination'},
    'select_pickup': {'fa': 'انتخاب مبدا (محل سوار شدن)', 'ps': 'د پورته کیدو ځای وټاکئ', 'en': 'Select Pickup'},
    'select_dropoff': {'fa': 'انتخاب مقصد (محل پیاده شدن)', 'ps': 'د ښکته کیدو ځای وټاکئ', 'en': 'Select Destination'},
    'confirm_pickup': {'fa': 'تایید مبدا', 'ps': 'مبدأ تایید کړئ', 'en': 'Confirm Pickup'},
    'confirm_destination': {'fa': 'تایید مقصد', 'ps': 'منزل تایید کړئ', 'en': 'Confirm Destination'},
    'driver_found': {'fa': 'راننده سفر شما را قبول کرد', 'ps': 'چلوونکي ستاسو سفر ومانه', 'en': 'Driver accepted your ride'},
    'driver_arriving': {'fa': 'راننده در حال رسیدن است', 'ps': 'چلوونکی د رسیدو په حال کې دی', 'en': 'Driver is arriving'},
    'confirm_cancel': {'fa': 'آیا از لغو سفر اطمینان دارید؟', 'ps': 'ایا تاسو ډاډه یاست چې سفر لغوه کوئ؟', 'en': 'Are you sure you want to cancel?'},
    'trip_history': {'fa': 'تاریخچه سفرها', 'ps': 'د سفرونو تاریخچه', 'en': 'Trip History'},
    'rate_driver': {'fa': 'امتیاز به راننده', 'ps': 'چلوونکي ته نمرې ورکول', 'en': 'Rate Driver'},
    'enter_rating_comment': {'fa': 'نظرتان در مورد این سفر چیست؟', 'ps': 'د دې سفر په اړه ستاسو نظر څه دی؟', 'en': 'What is your feedback?'},
    'submit_review': {'fa': 'ثبت نظر', 'ps': 'نظر ثبتول', 'en': 'Submit Review'},
    'saved_places': {'fa': 'مکان‌های ذخیره شده', 'ps': 'خوندي شوي ځایونه', 'en': 'Saved Places'},

    // --- مدیریت رانندگان، ثبت‌نام و اسناد (Admin & Driver App) ---
    'reg_title': {'fa': 'ثبت‌نام سفیر جدید', 'ps': 'د نوي سفیر نوم لیکنه', 'en': 'New Driver Registration'},
    'reg_success': {'fa': 'ثبت‌نام با موفقیت انجام شد', 'ps': 'نوم لیکنه بریالۍ وه', 'en': 'Registration successful'},
    'driver_list': {'fa': 'لیست رانندگان سفیر', 'ps': 'د سفیر چلوونکو لیست', 'en': 'Safir Drivers List'},
    'add_new_driver': {'fa': 'افزودن راننده جدید', 'ps': 'نوی چلوونکی زیات کړئ', 'en': 'Add New Driver'},
    'search_driver': {'fa': 'جستجوی راننده (نام یا شماره تلفن)...', 'ps': 'د چلوونکي پلټنه...', 'en': 'Search driver...'},
    'driver_details': {'fa': 'جزئیات اطلاعات راننده', 'ps': 'د چلوونکي د معلوماتو جزیات', 'en': 'Driver Details'},
    'full_name': {'fa': 'نام و نام خانوادگی', 'ps': 'بشپړ نوم', 'en': 'Full Name'},
    'father_name': {'fa': 'نام پدر', 'ps': 'د پلار نوم', 'en': 'Father\'s Name'},
    'phone': {'fa': 'شماره تماس', 'ps': 'د اړیکې شمیره', 'en': 'Phone Number'},
    'email': {'fa': 'ایمیل', 'ps': 'بریښنالیک', 'en': 'Email'},
    'address': {'fa': 'آدرس', 'ps': 'پته', 'en': 'Address'},
    'dob': {'fa': 'تاریخ تولد', 'ps': 'زیږون نیټه', 'en': 'Date of Birth'},
    'id_card': {'fa': 'نمبر تذکره / کارت ملی', 'ps': 'د تذکرې شمیره', 'en': 'ID Card Number'},
    'city_activity': {'fa': 'ولایت محل فعالیت', 'ps': 'د فعالیت ولایت', 'en': 'Working City'},
    'upload_doc': {'fa': 'بارگذاری مدارک', 'ps': 'اسناد اپلوډ کړئ', 'en': 'Upload Documents'},
    'image_too_large': {'fa': 'حجم عکس زیاد است (حداکثر ۲ مگ)', 'ps': 'د عکس اندازه لویه ده', 'en': 'Image too large (Max 2MB)'},
    'invalid_image_format': {'fa': 'فرمت تصویر نامعتبر است', 'ps': 'د عکس بڼه سمه نه ده', 'en': 'Invalid image format'},
    
    // --- لغات اختصاصی تصاویر اسناد هویتی ماشین و راننده ---
    'identity_docs': {'fa': 'تصاویر مدارک هویتی (کارت ملی):', 'ps': 'د هویت اسنادو انځورونه:', 'en': 'Identity Documents Images:'},
    'id_front': {'fa': 'روی کارت هویتی', 'ps': 'د ملي کارت مخ', 'en': 'ID Card Front'},
    'id_back': {'fa': 'پشت کارت هویتی', 'ps': 'د ملي کارت شا', 'en': 'ID Card Back'},
    'selfie_with_id': {'fa': 'سلفی با کارت هویتی', 'ps': 'له ملي کارت سره سیلفي', 'en': 'Selfie with ID'},
    'driving_license': {'fa': 'گواهینامه رانندگی:', 'ps': 'د چلولو جواز (لایسنس):', 'en': 'Driving License:'},
    'license_number': {'fa': 'شماره گواهینامه', 'ps': 'د لایسنس شمیره', 'en': 'License Number'},
    'license_front': {'fa': 'روی گواهینامه', 'ps': 'د لایسنس مخ', 'en': 'License Front'},
    'license_back': {'fa': 'پشت گواهینامه', 'ps': 'د لایسنس شا', 'en': 'License Back'},
    'car_card_front': {'fa': 'روی کارت ماشین', 'ps': 'د موټر کارت مخ', 'en': 'Car Card Front'},
    'car_card_back': {'fa': 'پشت کارت ماشین', 'ps': 'د موټر کارت شا', 'en': 'Car Card Back'},

    // --- وسایل نقلیه و اطلاعات موتر ---
    'vehicle_info_title': {'fa': 'مشخصات وسیله نقلیه', 'ps': 'د وسایطو مشخصات', 'en': 'Vehicle Specifications'},
    'vehicle_not_registered': {'fa': 'اطلاعات خودرو هنوز ثبت نشده است.', 'ps': 'د موټر معلومات لا ندي ثبت شوي.', 'en': 'Vehicle information is not registered yet.'},
    'vehicle_type': {'fa': 'نوع وسیله نقلیه', 'ps': 'د واسطې ډول', 'en': 'Vehicle Type'},
    'vehicle_car': {'fa': 'موتر (ماشین)', 'ps': 'موټر', 'en': 'Car'},
    'vehicle_bike': {'fa': 'موتورسایکل', 'ps': 'موټرسایکل', 'en': 'Motorcycle'},
    'vehicle_auto': {'fa': 'ریکشا', 'ps': 'ریکشا', 'en': 'Rickshaw'},
    'label_brand': {'fa': 'نام برند یا کمپنی (مثلاً تویوتا)', 'ps': 'د برانډ یا کپنۍ نوم (مثلا ټویوټا)', 'en': 'Brand or Company (e.g. Toyota)'},
    'label_color': {'fa': 'رنگ وسیله نقلیه', 'ps': 'د وسایطو رنګ', 'en': 'Vehicle Color'},
    'label_year': {'fa': 'سال تولید (مدل)', 'ps': 'د تولید کال (موډل)', 'en': 'Production Year (Model)'},
    'label_plate': {'fa': 'شماره پلاک یا نمبر پلیت', 'ps': 'د پلیټ نمبر', 'en': 'License Plate Number'},
    'safir_taxi': {'fa': 'سفیر سواری', 'ps': 'سوارلۍ سفیر', 'en': 'Safir Taxi'},
    'safir_cargo': {'fa': 'سفیر باربر', 'ps': 'بار وړونکی سفیر', 'en': 'Safir Cargo'},
    'safir_bike': {'fa': 'سفیر سریع (موتور)', 'ps': 'چټک سفیر', 'en': 'Safir Bike'},
    'safir_luxury': {'fa': 'سفیر لوکس', 'ps': 'لوکس سفیر', 'en': 'Safir Luxury'},
    'economic_car': {'fa': 'موتر اقتصادی', 'ps': 'اقتصادي موټر', 'en': 'Economic Car'},
    'modern_car': {'fa': 'موتر مدرن', 'ps': 'مډرن موټر', 'en': 'Modern Car'},

    // --- وضعیت‌های سفر و سفیر ---
    'status_updated': {'fa': 'وضعیت سفر بروزرسانی شد', 'ps': 'د سفر حالت بدل شو', 'en': 'Ride status updated'},
    'searching': {'fa': 'در جستجوی راننده', 'ps': 'د ډرایور په لټه کې', 'en': 'Searching'},
    'accepted': {'fa': 'تایید شده', 'ps': 'تایید شوی', 'en': 'Accepted'},
    'ride_accepted': {'fa': 'سفر با موفقیت قبول شد', 'ps': 'سفر په بریالیتوب سره قبول شو', 'en': 'Ride accepted successfully'},
    'arrived': {'fa': 'سفیر رسید', 'ps': 'سفیر راورسید', 'en': 'Arrived'},
    'picked_up': {'fa': 'مسافر سوار شد', 'ps': 'سپرلۍ پورته شوه', 'en': 'Passenger picked up'},
    'started': {'fa': 'سفر آغاز شد', 'ps': 'سفر پیل شو', 'en': 'Started'},
    'completed': {'fa': 'تکمیل شده', 'ps': 'بشپړ شوی', 'en': 'Completed'},
    'ride_completed_success': {'fa': 'سفر با موفقیت به پایان رسید', 'ps': 'سفر په بریالیتوب پای ته ورسید', 'en': 'Ride completed successfully'},
    'cancelled': {'fa': 'لغو شده', 'ps': 'لغوه شوی', 'en': 'Cancelled'},
    'is_approved': {'fa': 'وضعیت تایید', 'ps': 'د تایید حالت', 'en': 'Verification Status'},
    'not_approved': {'fa': 'منتظر تایید', 'ps': 'تایید ته انتظار', 'en': 'Pending'},
    'not_approved_yet': {'fa': 'حساب شما هنوز تایید نشده است', 'ps': 'ستاسو حساب لا نه دی تایید شوی', 'en': 'Account not approved yet'},

    // --- بخش مالی، کمیسیون و کیف پول ---
    'total_earned': {'fa': 'مجموع درآمد', 'ps': 'ټوله ګټه', 'en': 'Total Earned'},
    'wallet_balance': {'fa': 'موجودی کیف پول', 'ps': 'د بکس موجودي', 'en': 'Wallet Balance'},
    'commission': {'fa': 'حق کمیسیون', 'ps': 'د کمیسیون حق', 'en': 'Commission'},
    'driver_share': {'fa': 'سهم سفیر', 'ps': 'د سفیر برخه', 'en': 'Driver\'s Share'},
    'wallet_recharged': {'fa': 'کیف پول با موفقیت شارژ شد', 'ps': 'بکس په بریالیتوب سره چارج شو', 'en': 'Wallet recharged successfully'},
    'insufficient_balance': {'fa': 'موجودی کافی نیست', 'ps': 'ستاسو موجودي کمه ده', 'en': 'Insufficient balance'},
    'cash': {'fa': 'نقد', 'ps': 'نغدې', 'en': 'Cash'},
    'wallet': {'fa': 'کیف پول', 'ps': 'بکس (والټ)', 'en': 'Wallet'},
    'charge_wallet': {'fa': 'شارژ کیف پول', 'ps': 'د بټوې چارج کول', 'en': 'Top Up Wallet'},

    // --- افتخارات و پنل کناری (Side Panel) ---
    'manage_users': {'fa': 'مدیریت مسافران', 'ps': 'د مسافرینو مدیریت', 'en': 'Manage Users'},
    'top_driver_year': {'fa': 'سفیر برتر سال', 'ps': 'د کال غوره سفیر', 'en': 'Top Driver of the Year'},
    'honors_and_medals': {'fa': 'نشان‌های افتخار', 'ps': 'د ویاړ نښې', 'en': 'Honors & Medals'},
    'years': {'fa': 'ساله', 'ps': 'کلن', 'en': 'Years'},
    'popular': {'fa': 'محبوب', 'ps': 'محبوب', 'en': 'Popular'},
    'active_rides': {'fa': 'سفرهای فعال', 'ps': 'فعال سفرونه', 'en': 'Active Rides'},
    'referral_code': {'fa': 'کد معرف (اختیاری)', 'ps': 'د پیژندنې کوډ', 'en': 'Referral Code'},

    // --- مکان‌یابی و امنیت ---
    'gps_disabled': {'fa': 'لطفاً جی‌پی‌اس گوشی را روشن کنید', 'ps': 'مهرباني وکړئ GPS چالان کړئ', 'en': 'Please enable GPS'},
    'location_denied': {'fa': 'اجازه دسترسی به مکان داده نشد', 'ps': 'ځای ته د لاسرسي اجازه ورنکړل شوه', 'en': 'Location access denied'},
    'sos_sent_alert': {'fa': 'پیام اضطراری به مرکز ارسال شد', 'ps': 'بېړنی پیغام مرکز ته واستول شو', 'en': 'SOS alert sent to center'},
    'is_sos_active': {'fa': 'وضعیت اضطراری', 'ps': 'بیړنی حالت', 'en': 'SOS Active'},
    'distance': {'fa': 'مسافت (کیلومتر)', 'ps': 'واټن (کیلومتر)', 'en': 'Distance (KM)'},
    'rating': {'fa': 'امتیاز', 'ps': 'امتیاز', 'en': 'Rating'},

    // --- اختصاصی صفحه ورود رانندگان (Login Screen) ---
    'driver_login_title': {'fa': 'ورود رانندگان سفیر', 'ps': 'د سفیر چلوونکو ننوتل', 'en': 'Safir Driver Login'},
    'your_email': {'fa': 'ایمیل شما', 'ps': 'ستاسو بریښنالیک', 'en': 'Your Email'},
    'password': {'fa': 'رمز عبور', 'ps': 'پټ نوم (پاسورډ)', 'en': 'Password'},
    'login_btn': {'fa': 'ورود', 'ps': 'ننوتل', 'en': 'Login'},
    'no_account_signup': {'fa': 'حسابی ندارید؟ از اینجا ثبت‌نام کنید', 'ps': 'اکاونټ نلرئ؟ له دې ځایه نوم لیکنه وکړئ', 'en': 'Don\'t have an account? Sign Up here'},
    'logging_in': {'fa': 'در حال ورود به برنامه...', 'ps': 'پروګرام ته د ننوتلو په حال کې...', 'en': 'Logging in...'},
    'invalid_email_error': {'fa': 'لطفاً یک ایمیل معتبر وارد کنید.', 'ps': 'مهرباني وکړئ یو معتبر بریښنالیک دننه کړئ.', 'en': 'Please enter a valid email address.'},
    'password_length_error': {'fa': 'رمز عبور شما باید حداقل ۶ کاراکتر باشد.', 'ps': 'ستاسو پټ نوم باید لږترلږه ۶ توري وي.', 'en': 'Password must be at least 6 characters.'},
    'blocked_account_error': {'fa': 'حساب شما مسدود شده است. لطفاً با پشتیبانی سفیر تماس بگیرید.', 'ps': 'ستاسو حساب بلاک شوی دی. مهرباني وکړئ د سفیر ملاتړ سره اړیکه ونیسئ.', 'en': 'Your account has been blocked. Please contact Safir support.'},
    'no_driver_record': {'fa': 'رکورد شما به عنوان راننده در سیستم وجود ندارد.', 'ps': 'په سیسټم کې د چلوونکي په توګه ستاسو ریکارډ شتون نلري.', 'en': 'No driver record found for this account.'},

    // --- اختصاصی صفحه ثبت‌نام رانندگان (SignUp Screen) ---
    'choose_profile_pic': {'fa': 'انتخاب عکس پروفایل', 'ps': 'د پروفایل عکس غوره کړئ', 'en': 'Select Profile Picture'},
    'register_btn': {'fa': 'ثبت‌نام راننده', 'ps': 'د چلونکي نوم لیکنه', 'en': 'Register Driver'},
    'already_have_account': {'fa': 'قبلاً ثبت‌نام کرده‌اید؟ از اینجا وارد شوید', 'ps': 'مخکې له مخکې اکاونټ لرئ؟ ننوځئ', 'en': 'Already have an account? Login here'},
    'registering_account': {'fa': 'در حال ثبت حساب کاربری شما...', 'ps': 'ستاسو د اکاونټ ثبتولو په حال کې...', 'en': 'Registering your account...'},
    'select_pic_error': {'fa': 'لطفاً ابتدا عکس پروفایل خود را انتخاب کنید.', 'ps': 'مهرباني وکړئ لومړی د پروفایل عکس وټاکئ.', 'en': 'Please select your profile picture first.'},
    'name_length_error': {'fa': 'نام شما باید حداقل ۴ کاراکتر باشد.', 'ps': 'ستاسو نوم باید لږترلږه ۴ توري وي.', 'en': 'Name must be at least 4 characters.'},
    'phone_length_error': {'fa': 'شماره تلفن باید حداقل ۸ رقم باشد.', 'ps': 'د تلیفون شمیره باید لږترلږه ۸ شمیرې وي.', 'en': 'Phone number must be at least 8 digits.'},
    
    // --- اختصاصی متدهای عمومی (Common Methods) ---
    'no_internet_error': {'fa': 'اتصال اینترنت شما برقرار نیست. لطفاً شبکه خود را بررسی کرده و دوباره تلاش کنید.', 'ps': 'ستاسو انټرنیټ وصل نه دی. مهرباني وکړئ خپله شبکه وڅیړئ او بیا هڅه وکړئ.', 'en': 'Your internet connection is offline. Please check your network and try again.'},

    // --- اختصاصی دکمه‌های وضعیت سفر ---
    'btn_arrived': {'fa': 'رسیدم به مبدأ', 'ps': 'مبدأ ته ورسیدم', 'en': 'Arrived'},
    'btn_start_trip': {'fa': 'شروع سفر', 'ps': 'سفر پیل کړئ', 'en': 'Start Trip'},
    'btn_end_trip': {'fa': 'پایان سفر', 'ps': 'سفر پای ته ورسوئ', 'en': 'End Trip'},
    'ending_trip': {'fa': 'در حال اتمام سفر...', 'ps': 'د سفر د پای ته رسولو په حال کې...', 'en': 'Ending trip...'},

    // --- اختصاصی صفحه ورود کد OTP ---
    'otp_title': {'fa': 'تأیید کد دسترسی', 'ps': 'د لاسرسي کوډ تایید', 'en': 'Verify OTP Code'},
    'otp_subtitle': {'fa': 'کد ۶ رقمی ارسال شده به شماره موبایل خود را وارد کنید', 'ps': 'هغه ۶ رقمي کوډ داخل کړئ چې ستاسو موبایل ته استول شوی', 'en': 'Enter the 6-digit code sent to your phone'},
    'didnt_receive_code': {'fa': 'کد را دریافت نکرده‌اید؟', 'ps': 'کوډ مو نه دی ترلاسه کړی؟', 'en': 'Didn\'t receive code?'},
    'resend_code': {'fa': 'ارسال مجدد', 'ps': 'بیا استول', 'en': 'Resend'},
    'complete_documents_error': {'fa': 'لطفاً اطلاعات و مدارک ناقص خود را تکمیل کنید.', 'ps': 'مهرباني وکړئ خپل نیمګړي اسناد او معلومات بشپړ کړئ.', 'en': 'Please complete your pending documents and information.'},

    // --- اختصاصی صفحه ورود و ثبت نام (RegisterScreen) ---
    'register_title': {'fa': 'ورود یا ثبت‌نام راننده سفیر', 'ps': 'د سفیر چلونکي ننوتل یا راجستر', 'en': 'Safir Driver Login or Register'},
    'register_subtitle': {'fa': 'لطفاً شماره موبایل خود را بدون صفر وارد کنید', 'ps': 'مهرباني وکړئ خپل موبایل شمیره بې له صفر داخل کړئ', 'en': 'Please enter your mobile number without zero'},
    'btn_continue': {'fa': 'ادامه', 'ps': 'ادامه', 'en': 'Continue'},
    'or_label': {'fa': 'یا', 'ps': 'یا', 'en': 'Or'},
    'google_sign_in': {'fa': 'ادامه با حساب گوگل', 'ps': 'د ګوګل حساب سره دوام ورکړئ', 'en': 'Continue with Google'},
    'terms_and_conditions': {'fa': 'با ادامه کار، شما موافقت خود را با قوانین و مقررات سفیر جهت دریافت تماس، پیام در واتساپ یا پیامک تأیید هویت اعلام می‌دارید.', 'ps': 'د کار په دوام سره، تاسو د هویت تایید پیغامونو یا اړیکو ترلاسه کولو لپاره د سفیر د قوانینو او مقرراتو سره خپل موافقت اعلانوئ.', 'en': 'By continuing, you agree to Safir\'s terms and conditions to receive verification calls, SMS, or WhatsApp messages.'},
    'invalid_phone_error': {'fa': 'لطفاً یک شماره موبایل معتبر (مثل 771234567) وارد کنید.', 'ps': 'مهرباني وکړئ یو باوري موبایل شمیره (لکه 771234567) داخل کړئ.', 'en': 'Please enter a valid mobile number (e.g., 771234567).'},

    // --- اختصاصی صفحه آپلود عکس وسیله نقلیه (DriverCarImageScreeen) ---
    'vehicle_image_hint': {'fa': 'لطفاً یک عکس واضح از نمای روبه‌رو یا جانبی وسیله نقلیه خود قرار دهید.', 'ps': 'مهرباني وکړئ د خپلې وسایطې واضح انځور له مخې یا اړخ څخه واخلئ.', 'en': 'Please upload a clear front or side photo of your vehicle.'},
    'take_photo_camera': {'fa': 'گرفتن عکس با دوربین', 'ps': 'د کلمې په واسطه انځور اخیستل', 'en': 'Take Photo with Camera'},
    'confirm_and_save': {'fa': 'تأیید و ذخیره', 'ps': 'تایید او خوندي کول', 'en': 'Confirm and Save'},

    // --- اختصاصی صفحه مشخصات وسیله نقلیه (VehicleBasicInfoScreen) ---
    'err_brand_required': {'fa': 'وارد کردن نام برند الزامی است', 'ps': 'د برانډ نوم د ننه کول اړین دي', 'en': 'Brand name is required'},
    'err_color_required': {'fa': 'وارد کردن رنگ الزامی است', 'ps': 'د رنګ د ننه کول اړین دي', 'en': 'Color is required'},
    'err_year_required': {'fa': 'وارد کردن سال تولید الزامی است', 'ps': 'د تولید کال د ننه کول اړین دي', 'en': 'Production year is required'},
    'err_plate_required': {'fa': 'وارد کردن شماره پلاک الزامی است', 'ps': 'د پلیټ نمبر د ننه کول اړین دي', 'en': 'Plate number is required'},
    'btn_confirm_register': {'fa': 'تأیید و ثبت', 'ps': 'تایید او ثبت کول', 'en': 'Confirm & Register'},

    // --- اختصاصی صفحه جواز سیر / سند وسیله نقلیه (VehicleRegistrationScreen) ---
    'vehicle_registration_title': {'fa': 'جواز سیر (سند وسیله نقلیه)', 'ps': 'د جواز سیر (سند) عکسونه', 'en': 'Vehicle Registration Document'},
    'registration_front_title': {'fa': 'تصویر روی جواز سیر (سند)', 'ps': 'د جواز سیر د مخ انځور', 'en': 'Vehicle Registration Front Image'},
    'registration_back_title': {'fa': 'تصویر پشت جواز سیر (سند)', 'ps': 'د جواز سیر د شا انځور', 'en': 'Vehicle Registration Back Image'},
    'take_photo_front': {'fa': 'گرفتن عکس از رو', 'ps': 'د مخ انځور اخیستل', 'en': 'Take Front Photo'},
    'take_photo_back': {'fa': 'گرفتن عکس از پشت', 'ps': 'د شا انځور اخیستل', 'en': 'Take Back Photo'},
    'confirm_and_save_final': {'fa': 'تأیید و ذخیره نهایی', 'ps': 'تایید او وروستی خوندي کول', 'en': 'Confirm and Final Save'},
        // --- اختصاصی صفحه اطلاعات فردی (BasicInfoScreen) ---
    'basic_info_title': {'fa': 'اطلاعات فردی راننده', 'ps': 'د چلوونکي شخصي معلومات', 'en': 'Driver Personal Info'},
    'add_profile_photo': {'fa': 'افزودن عکس پروفایل *', 'ps': 'د پروفایل عکس زیاتول *', 'en': 'Add Profile Photo *'},
    'first_name': {'fa': 'نام', 'ps': 'نوم', 'en': 'First Name'},
    'last_name': {'fa': 'تخلص (نام خانوادگی)', 'ps': 'تخلص (کورنی نوم)', 'en': 'Last Name'},
    'home_address': {'fa': 'آدرس سکونت', 'ps': 'د استوګنې پته', 'en': 'Residential Address'},
    'mobile_number': {'fa': 'شماره تلفن همراه', 'ps': 'د موبایل شمیره', 'en': 'Mobile Number'},
    'err_first_name': {'fa': 'وارد کردن نام الزامی است', 'ps': 'د نوم د ننه کول اړین دي', 'en': 'First name is required'},
    'err_last_name': {'fa': 'وارد کردن تخلص الزامی است', 'ps': 'د تخلص د ننه کول اړین دي', 'en': 'Last name is required'},
    'err_address': {'fa': 'لطفاً آدرس دقیق و معتبر خود را وارد کنید', 'ps': 'مهرباني وکړئ خپله دقیقه پته دننه کړئ', 'en': 'Please enter a valid address'},
    'err_phone': {'fa': 'شماره تلفن وارد شده معتبر نیست', 'ps': 'داخل شوې د تلیفون شمیره د اعتبار وړ نه ده', 'en': 'Invalid phone number'},
    'confirm_and_submit': {'fa': 'تأیید و ثبت اطلاعات', 'ps': 'د معلوماتو تایید او ثبتول', 'en': 'Confirm & Submit Info'},
    
        // --- اختصاصی صفحه تذکره / کارت هویت (CNICScreen) ---
    'cnic_screen_title': {'fa': 'تذکره / کارت هویت راننده', 'ps': 'د چلوونکي تذکره / د هویت کارت', 'en': 'Driver ID / CNIC Card'},
    'cnic_front_hint': {'fa': 'تصویر روی تذکره / کارت هویت (ابتدا عکس بگیرید سپس برش دهید)', 'ps': 'د تذکرې / هویت کارت د مخ انځور', 'en': 'ID Card Front Image'},
    'cnic_back_hint': {'fa': 'تصویر پشت تذکره / کارت هویت (ابتدا عکس بگیرید سپس برش دهید)', 'ps': 'د تذکرې / هویت کارت د شا انځور', 'en': 'ID Card Back Image'},
    'cnic_number_label': {'fa': 'شماره تذکره / کارت هویت', 'ps': 'د تذکرې / هویت کارت شمیره', 'en': 'ID / CNIC Number'},
    'err_cnic_required': {'fa': 'وارد کردن شماره هویت الزامی است', 'ps': 'د هویت شمیرې دننه کول اړین دي', 'en': 'ID number is required'},
    'err_cnic_length': {'fa': 'شماره هویت باید دقیقاً ۱۳ رقم باشد', 'ps': 'د هویت شمیره باید په دقیق ډول ۱۳ رقمونه وي', 'en': 'ID number must be exactly 13 digits'},

  };

  return words[key]?[lang] ?? key;
}
