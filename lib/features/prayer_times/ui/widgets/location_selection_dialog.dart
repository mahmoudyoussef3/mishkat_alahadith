import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/models/location_model.dart';

class LocationSelectionDialog extends StatefulWidget {
  final LocationModel currentLocation;
  final Function(LocationModel) onLocationSelected;
  final VoidCallback onUseCurrentLocation;

  const LocationSelectionDialog({
    super.key,
    required this.currentLocation,
    required this.onLocationSelected,
    required this.onUseCurrentLocation,
  });

  @override
  State<LocationSelectionDialog> createState() => _LocationSelectionDialogState();
}

class _LocationSelectionDialogState extends State<LocationSelectionDialog> {
  bool _isLoadingLocation = false;

  void _handleUseCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    Navigator.pop(context);
    widget.onUseCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          constraints: BoxConstraints(maxHeight: 600.h),
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: ColorsManager.primaryPurple,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'اختر الموقع',
                    style: TextStyles.headlineSmall.copyWith(
                      color: ColorsManager.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: ColorsManager.secondaryText,
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Current Location Button
              _buildCurrentLocationButton(context),
              
              SizedBox(height: 16.h),
              
              Divider(color: ColorsManager.mediumGray),
              
              SizedBox(height: 8.h),

              // City List Header
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'اختر مدينة',
                  style: TextStyles.bodyLarge.copyWith(
                    color: ColorsManager.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              SizedBox(height: 12.h),

              // Cities List
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: LocationModel.egyptianCities.length,
                  itemBuilder: (context, index) {
                    final city = LocationModel.egyptianCities[index];
                    final isSelected = city.cityName == widget.currentLocation.cityName;
                    return _buildCityTile(context, city, isSelected);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationButton(BuildContext context) {
    return InkWell(
      onTap: _isLoadingLocation ? null : _handleUseCurrentLocation,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: ColorsManager.primaryGreen.withOpacity(_isLoadingLocation ? 0.05 : 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: ColorsManager.primaryGreen.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: ColorsManager.primaryGreen.withOpacity(_isLoadingLocation ? 0.5 : 1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: _isLoadingLocation
                  ? SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 20.sp,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLoadingLocation ? 'جاري تحديد الموقع...' : 'استخدام الموقع الحالي',
                    style: TextStyles.bodyLarge.copyWith(
                      color: ColorsManager.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'الحصول على مواقيت دقيقة بناءً على موقعك',
                    style: TextStyles.bodySmall.copyWith(
                      color: ColorsManager.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_back_ios,
              size: 16.sp,
              color: ColorsManager.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityTile(BuildContext context, LocationModel city, bool isSelected) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        widget.onLocationSelected(city);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryPurple.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryPurple
                : ColorsManager.mediumGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_city,
              color: isSelected
                  ? ColorsManager.primaryPurple
                  : ColorsManager.secondaryText,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                city.cityName,
                style: TextStyles.bodyLarge.copyWith(
                  color: isSelected
                      ? ColorsManager.primaryPurple
                      : ColorsManager.primaryText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: ColorsManager.primaryPurple,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
