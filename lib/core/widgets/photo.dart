import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/photos.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import 'ui.dart';

export '../../data/photos.dart';

/// A cover-fit photo that fades in once decoded, with an optional darkening scrim so text
/// laid over it stays readable (contrast rule).
class Photo extends StatelessWidget {
  const Photo(
    this.photo, {
    super.key,
    this.alignment = Alignment.center,
    this.scrim,
    this.label,
  });

  final Photos photo;
  final Alignment alignment;
  final Gradient? scrim;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Semantics(
      image: true,
      label: label ?? photo.caption,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth.isFinite ? (c.maxWidth * dpr).round() : null;
          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.nightRaised),
              Image.asset(
                photo.asset,
                fit: BoxFit.cover,
                alignment: alignment,
                cacheWidth: w, // decode at display size: low memory on budget phones (NFR-11)
                excludeFromSemantics: true,
                frameBuilder: (context, child, frame, sync) => sync
                    ? child
                    : AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : Motion.short,
                        curve: Motion.enter,
                        child: child,
                      ),
              ),
              if (scrim != null)
                DecoratedBox(decoration: BoxDecoration(gradient: scrim)),
            ],
          );
        },
      ),
    );
  }
}

abstract final class Scrims {
  /// Darkens the bottom for a caption.
  static const bottom = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.3, 1],
    colors: [Color(0x00211D18), Color(0xE6211D18)],
  );

  /// Darkens top (status bar icons) and bottom (headline).
  static const both = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.22, 0.5, 1],
    colors: [
      Color(0xA6211D18),
      Color(0x26211D18),
      Color(0x8C211D18),
      Color(0xF7211D18),
    ],
  );

  /// Darkens the left for a title.
  static const left = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.15, 0.9],
    colors: [Color(0xEB211D18), Color(0x22211D18)],
  );
}

/// Page with a full-bleed photo header (stretches on overscroll), title set on the photo,
/// and a padded body below. Used where a picture carries the page: articles, Ramadan,
/// centenary, events.
class PhotoScreen extends StatelessWidget {
  const PhotoScreen({
    super.key,
    required this.photo,
    required this.title,
    required this.children,
    this.subtitle,
    this.eyebrow,
    this.overlay,
    this.height = 340,
    this.footer,
  });

  final Widget photo;
  final String title;
  final String? subtitle;
  final Widget? eyebrow;

  /// Extra content set on the photo under the title (e.g. a countdown).
  final Widget? overlay;
  final double height;
  final Widget? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: height + top,
              collapsedHeight: kToolbarHeight,
              stretch: true,
              backgroundColor: AppColors.night,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leadingWidth: 64,
              leading: Padding(
                padding: const EdgeInsets.only(left: Space.sm),
                child: IconBtn(
                  icon: Icons.arrow_back_rounded,
                  label: t.back,
                  onPhoto: true,
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    photo,
                    Positioned(
                      left: Space.lg,
                      right: Space.lg,
                      bottom: Space.xl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (eyebrow != null) ...[
                            eyebrow!,
                            const SizedBox(height: Space.sm),
                          ],
                          Text(
                            title,
                            style: AppText.title.copyWith(
                              color: AppColors.onNight,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: Space.xs),
                            Text(
                              subtitle!,
                              style: AppText.label.copyWith(
                                color: AppColors.onNightMuted,
                              ),
                            ),
                          ],
                          ?overlay,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                Space.lg,
                Space.xl,
                Space.lg,
                Space.xxl +
                    (footer == null ? MediaQuery.paddingOf(context).bottom : 0),
              ),
              sliver: SliverList.list(children: gap(children, Space.lg)),
            ),
          ],
        ),
        bottomNavigationBar: footer == null
            ? null
            : DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  border: Border(top: BorderSide(color: AppColors.line)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(Space.md),
                    child: footer,
                  ),
                ),
              ),
      ),
    );
  }
}
