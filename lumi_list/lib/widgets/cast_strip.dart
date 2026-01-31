import 'package:flutter/material.dart';
import '../models/cast.dart';

class CastStrip extends StatelessWidget {
  final List<CastMember> cast;

  const CastStrip({
    super.key,
    required this.cast,
  });

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final c = cast[index];
              return SizedBox(
                width: 80,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: c.profileUrl != null
                          ? NetworkImage(c.profileUrl!)
                          : null,
                      child: c.profileUrl == null
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
