import 'package:flutter/material.dart';

class LanguageChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const LanguageChip({super.key, required this.label, required this.backgroundColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style:  TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final Color ratingColor;
  final Color reviewCountColor;

  const RatingRow(
      {super.key, required this.rating, required this.reviewCount,required this.ratingColor, required this.reviewCountColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
         Icon(Icons.star, size: 14, color: Color(0xFFD8B66A)),
         SizedBox(width: 4),
        Text(
          rating.toString(),
          style:  TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ratingColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount)',
          style:  TextStyle(fontSize: 12, color: reviewCountColor),
        ),
      ],
    );
  }
}


