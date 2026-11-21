import 'dart:io';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:business_map/view/custom_widgets/snack_bar/custom_snackbar.dart';
import 'package:business_map/view/custom_widgets/textfield/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/shimmer/custom_shimmer.dart';
import 'package:business_map/view/custom_widgets/text/section_label.dart';
import 'package:provider/provider.dart';
import '../../../provider/profile/profile_provider.dart';
import '../../custom_widgets/others/image_viewer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    _nameController.text = profileProvider.userProfile?.name ?? " ";
    _emailController.text = profileProvider.userProfile?.email ?? "Not Found";

    _nameController.addListener(() {
      final hasChanged =
          _nameController.text.trim() !=
          profileProvider.userProfile?.name?.trim();
      profileProvider.setNameChanged(hasChanged);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Profile")),
      body: SafeArea(
        child: SizedBox(
          width: SizeConfig.screenWidth,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    SizeConfig.screenHeight -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.width(20),
                  vertical: SizeConfig.height(10),
                ),
                child: Consumer<ProfileProvider>(
                  builder: (context, provider, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (provider.userProfile?.imageUrl != null &&
                                        provider.userProfile!.imageUrl!.isNotEmpty) {
                                      ImageViewer.show(context, provider.userProfile!.imageUrl!);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: SizeConfig.width(60),
                                      backgroundColor: theme.colorScheme.surface,
                                      child: ClipOval(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (provider.file != null)
                                              Image.file(
                                                File(provider.file!.path),
                                                fit: BoxFit.cover,
                                                width: SizeConfig.width(120),
                                                height: SizeConfig.width(120),
                                              )
                                            else if (provider.userProfile?.imageUrl != null &&
                                                provider.userProfile!.imageUrl!.isNotEmpty)
                                              CachedNetworkImage(
                                                imageUrl: provider.userProfile!.imageUrl!,
                                                fit: BoxFit.cover,
                                                width: SizeConfig.width(120),
                                                height: SizeConfig.width(120),
                                                placeholder: (context, url) => CustomShimmer(
                                                  height: SizeConfig.width(120),
                                                  width: SizeConfig.width(120),
                                                  borderRadius: BorderRadius.circular(60),
                                                ),
                                                errorWidget: (context, url, error) => Icon(
                                                  Icons.person,
                                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                                  size: SizeConfig.width(60),
                                                ),
                                              )
                                            else
                                              Icon(
                                                Icons.person,
                                                color: theme.colorScheme.primary.withOpacity(0.5),
                                                size: SizeConfig.width(60),
                                              ),
                                            if (provider.isLoading &&
                                                provider.loadingFor == ProfileLoadingFor.uploadImage)
                                              const CircularProgressIndicator(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _updateProfilePicture(context),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      SizeConfig.width(6),
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: SizeConfig.icon(16),
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: SizeConfig.height(20)),


                        SectionLabel(
                          label: "Name",
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {
                              FocusScope.of(context).requestFocus(_nameFocusNode);
                              provider.setEnable(true);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        CustomTextField(
                          controller: _nameController,
                          leadingIcon: Icons.person_outline_outlined,
                          focusNode: _nameFocusNode,
                          isReadOnly: !provider.isEditEnable,
                        ),
                        SizedBox(height: SizeConfig.height(20)),

                        const SectionLabel(label: "Email", bottomPadding: 10),
                        CustomTextField(
                          controller: _emailController,
                          isReadOnly: true,
                          leadingIcon: Icons.email_outlined,
                        ),
                        SizedBox(height: SizeConfig.height(20)),
                        AppPrimaryButton(
                          text: "Save Changes",
                          onPressed: () {
                            _updateProfile(context, _nameController.text);
                          },
                          isDisabled: !provider.isNameChanged,
                          isLoading:
                              provider.isLoading &&
                              provider.loadingFor ==
                                  ProfileLoadingFor.updateUser,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateProfilePicture(BuildContext context) {
    final provider = context.read<ProfileProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.height(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _handleImageProcess(
                  provider.captureFromCamera(context),
                  "Photo updated successfully",
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _handleImageProcess(
                  provider.pickFromGallery(context),
                  "Photo updated successfully",
                );
              },
            ),
            if (provider.userProfile?.imageUrl != null &&
                provider.userProfile!.imageUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Remove Image",
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageProcess(
                    provider.removeProfileImage(),
                    "Photo removed successfully",
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handleImageProcess(Future<bool> action, String successMsg) async {
    final success = await action;
    if (!mounted) return;
    final provider = context.read<ProfileProvider>();
    if (success) {
      CustomSnackbar.show(
        context: context,
        message: successMsg,
        isError: false,
      );
    } else if (provider.errorMsg != null) {
      CustomSnackbar.show(
        context: context,
        message: provider.errorMsg!,
        isError: true,
      );
    }
  }

  void _updateProfile(BuildContext context, String name) async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final success = await provider.updateUserName(_nameController.text);
    if (success) {
      if (context.mounted) {
        Navigator.pop(context);
        CustomSnackbar.show(
          context: context,
          message: "Successfully Updated",
          isError: false,
        );
      }
    } else {
      if (context.mounted) {
        CustomSnackbar.show(
          context: context,
          message: provider.errorMsg ?? "Unexpected Error Occur",
          isError: true,
        );
      }
    }
  }
}
