import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GradientDropdown extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;

  const GradientDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    this.value,
    this.onChanged,
  });

  @override
  State<GradientDropdown> createState() =>
      _GradientDropdownState();
}

class _GradientDropdownState
    extends State<GradientDropdown> {
  String? selected;

  @override
  void initState() {
    super.initState();

    _initializeSelectedValue();
  }

  // ----------------------------------------------------------
  // Initialize selected value safely
  // ----------------------------------------------------------

  void _initializeSelectedValue() {
    if (widget.value != null &&
        widget.items.contains(widget.value)) {
      selected = widget.value;
    } else if (widget.items.isNotEmpty) {
      selected = widget.items.first;
    } else {
      selected = null;
    }
  }

  // ----------------------------------------------------------
  // Update when parent changes value
  // ----------------------------------------------------------

  @override
  void didUpdateWidget(
      covariant GradientDropdown oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value ||
        widget.items != oldWidget.items) {
      _initializeSelectedValue();
    }
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        // ------------------------------------------------------
        // LABEL
        // ------------------------------------------------------

        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  const LinearGradient(
                    colors: [
                      Color(0xff20D5FF),
                      Color(0xffCC3EFF),
                    ],
                  ).createShader(bounds),

              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                widget.label,

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 14,
        ),

        // ------------------------------------------------------
        // OUTER GRADIENT
        // ------------------------------------------------------

        Container(
          padding:
          const EdgeInsets.all(1),

          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(18),

            gradient:
            const LinearGradient(
              colors: [
                Color(0xff20D5FF),
                Color(0xffCC3EFF),
              ],
            ),
          ),

          // ----------------------------------------------------
          // INNER CONTAINER
          // ----------------------------------------------------

          child: Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 18,
            ),

            decoration:
            BoxDecoration(
              color:
              AppColors.background,

              borderRadius:
              BorderRadius.circular(17),
            ),

            // --------------------------------------------------
            // DROPDOWN
            // --------------------------------------------------

            child:
            DropdownButtonHideUnderline(
              child:
              DropdownButton<String>(
                value: selected,

                isExpanded: true,

                dropdownColor:
                AppColors.card,

                icon: const Icon(
                  Icons
                      .keyboard_arrow_down_rounded,

                  color:
                  AppColors.greyText,

                  size: 28,
                ),

                style:
                const TextStyle(
                  color:
                  Colors.white,

                  fontSize: 18,
                ),

                // ------------------------------------------------
                // ITEMS
                // ------------------------------------------------

                items: widget.items
                    .map(
                      (
                      item,
                      ) =>
                      DropdownMenuItem<
                          String>(
                        value: item,

                        child:
                        Text(item),
                      ),
                )
                    .toList(),

                // ------------------------------------------------
                // ON CHANGE
                // ------------------------------------------------

                onChanged: (value) {
                  setState(() {
                    selected = value;
                  });

                  widget.onChanged
                      ?.call(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}