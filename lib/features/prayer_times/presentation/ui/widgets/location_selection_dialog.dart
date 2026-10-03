import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/models/location_model.dart';

class LocationSelectionDialog extends StatefulWidget {
  final LocationModel currentLocation;
  final ValueChanged<LocationModel> onLocationSelected;
  final VoidCallback onUseCurrentLocation;

  const LocationSelectionDialog({
    super.key,
    required this.currentLocation,
    required this.onLocationSelected,
    required this.onUseCurrentLocation,
  });

  @override
  State<LocationSelectionDialog> createState() =>
      _LocationSelectionDialogState();
}

class _LocationSelectionDialogState extends State<LocationSelectionDialog> {
  bool _isLoadingLocation = false;

  void _handleUseCurrentLocation() {
    setState(() => _isLoadingLocation = true);
    Navigator.pop(context);
    widget.onUseCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Container(
          constraints: BoxConstraints(maxHeight: 650.h),
          decoration: BoxDecoration(
            color: ColorsManager.secondaryBackground,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: ColorsManager.primaryPurple,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'اختر موقعك',
                        style: TextStyles.headlineSmall.copyWith(
                          color: ColorsManager.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, size: 24.sp),
                      color: ColorsManager.secondaryText,
                      style: IconButton.styleFrom(
                        backgroundColor: ColorsManager.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      _buildCurrentLocationButton(),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: ColorsManager.mediumGray.withOpacity(0.5),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              'أو اختر مدينة',
                              style: TextStyles.bodyMedium.copyWith(
                                color: ColorsManager.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: ColorsManager.mediumGray.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 20.h),
                          itemCount: LocationModel.egyptianCities.length,
                          separatorBuilder:
                              (context, index) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final city = LocationModel.egyptianCities[index];
                            final isSelected =
                                city.cityName ==
                                widget.currentLocation.cityName;
                            return _buildCityTile(city, isSelected);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoadingLocation ? null : _handleUseCurrentLocation,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: ColorsManager.primaryPurple.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: ColorsManager.primaryPurple.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: ColorsManager.primaryPurple,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child:
                    _isLoadingLocation
                        ? Padding(
                          padding: EdgeInsets.all(14.r),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'استخدام الموقع الحالي',
                      style: TextStyles.titleMedium.copyWith(
                        color: ColorsManager.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'المواقيت الأدق لموقعك',
                      style: TextStyles.bodySmall.copyWith(
                        color: ColorsManager.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded, // RTL correct direction
                size: 16.sp,
                color: ColorsManager.primaryPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityTile(LocationModel city, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          widget.onLocationSelected(city);
        },
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? ColorsManager.primaryPurple.withOpacity(0.1)
                    : ColorsManager.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color:
                  isSelected
                      ? ColorsManager.primaryPurple
                      : ColorsManager.lightGray,
              width: isSelected ? 2 : 1,
            ),
            boxShadow:
                isSelected
                    ? []
                    : [
                      BoxShadow(
                        color: ColorsManager.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? ColorsManager.primaryPurple
                          : ColorsManager.lightGray.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  color:
                      isSelected ? Colors.white : ColorsManager.secondaryText,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  city.cityName,
                  style: TextStyles.titleMedium.copyWith(
                    color:
                        isSelected
                            ? ColorsManager.primaryPurple
                            : ColorsManager.primaryText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
