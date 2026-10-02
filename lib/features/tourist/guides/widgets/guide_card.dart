import 'package:flutter/material.dart';
import 'package:triply/core/widgets/guide_shared_widgets.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';

class GuideCard extends StatelessWidget {
  final Guide guide;
  final VoidCallback? onTap;
  final VoidCallback? onChatPressed;

  const GuideCard({
    super.key,
    required this.guide,
    this.onTap,
    this.onChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding:  EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFAAB8BC).withOpacity(.6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                guide.avatarUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 56,
                  height: 56,
                  color: Color(0xFF0E5261).withOpacity(.2),
                  alignment: Alignment.center,
                  child: Text(
                    guide.name.isNotEmpty ? guide.name[0] : '?',
                    style:  TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0E5261),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                       Text(
                          guide.name,
                          style:  TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0E5261),
                          ),
                        ),
                      SizedBox(width: 15,),
                      if (guide.isVerified)
                         Icon(Icons.verified,
                            size: 14, color: Color(0xFF4DA7A0)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    guide.specialty,
                    style:  TextStyle(
                        fontSize: 12, color: Color(0xFF8A9EA3)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: guide.languages
                        .map((l) => LanguageChip(label: l, backgroundColor: Color(0xFF4DA7A0).withOpacity(.1), textColor: Color(0xFF4DA7A0),))
                        .toList(),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingRow(
                          rating: guide.rating,
                          reviewCount: guide.reviewCount, ratingColor: Color(0xFF0E5261), reviewCountColor: Color(0xFFAAB8BC),),
                      const Spacer(),
                      Text.rich(
                        TextSpan(
                          children: [
                             TextSpan(
                              text: 'From ',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFE07A4F)),
                            ),
                            TextSpan(
                              text:
                                  '${guide.currency}${guide.pricePerHour.toStringAsFixed(0)}',
                              style:  TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color:Color(0xFFE07A4F) ,
                              ),
                            ),
                            const TextSpan(
                              text: '/hr',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFAAB8BC)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // const SizedBox(width: 8),
            // InkWell(
            //   onTap: onChatPressed,
            //   borderRadius: BorderRadius.circular(20),
            //   child: Container(
            //     width: 32,
            //     height: 32,
            //     decoration:  BoxDecoration(
            //       color: Color(0xFF4DA7A0).withOpacity(.15),
            //       shape: BoxShape.circle,
            //     ),
            //     child:  Icon(Icons.chat_outlined,
            //         size: 16, color: Color(0xFF4DA7A0)),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
