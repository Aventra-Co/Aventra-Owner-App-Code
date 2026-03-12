import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget tripsShimmerEffect(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    width: MediaQuery.of(context).size.width * 100 / 100,
    child: Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 3 / 100,
        ),
        Wrap(
          children: List.generate(
            5,
            (index) {
              return Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 90 / 100,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Row(
                              // Changed to simple Row
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      4 /
                                      100,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      15 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      15 /
                                      100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        3 /
                                        100),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          30 /
                                          100, // Reduced width
                                      height: 15,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          20 /
                                          100, // Reduced width
                                      height: 10,
                                      color: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100),
                ],
              );
            },
          ),
        ),
        // User info shimmer
      ],
    ),
  );
}

Widget myAdsShimmerEffect(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: List.generate(
          2, // Number of shimmer items to show
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Card container
                Container(
                  width: screenWidth * 0.9,
                  height: MediaQuery.of(context).size.height * 20 / 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget ratingShimmerEffect(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16.0),
      child: Column(
        children: List.generate(
          5, // Number of shimmer items to show
          (index) => Column(
            children: [
              // Card container
              Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300]!,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Circular avatar placeholder
                      Container(
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.grey[400]!,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text content placeholders
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: screenWidth * 0.5,
                              height: 16,
                              color: Colors.grey[400]!,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: screenWidth * 0.4,
                              height: 12,
                              color: Colors.grey[400]!,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: screenWidth * 0.3,
                              height: 12,
                              color: Colors.grey[400]!,
                            ),
                          ],
                        ),
                      ),
                      // Rating placeholder
                      Container(
                        width: screenWidth * 0.15,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[400]!,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget boatsShimmerEffect(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: List.generate(
          4, // Number of shimmer items to show
          (index) => Column(
            children: [
              // Card container
              Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[300]!,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Circular avatar placeholder
                      Container(
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.grey[400]!,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text content placeholders
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: screenWidth * 0.5,
                              height: 16,
                              color: Colors.grey[400]!,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: screenWidth * 0.4,
                              height: 12,
                              color: Colors.grey[400]!,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: screenWidth * 0.3,
                              height: 12,
                              color: Colors.grey[400]!,
                            ),
                          ],
                        ),
                      ),
                      // Rating placeholder
                      Container(
                        width: screenWidth * 0.15,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[400]!,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget staffShimmerEffect(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    width: MediaQuery.of(context).size.width * 100 / 100,
    child: Column(
      children: [
        Wrap(
          children: List.generate(
            5,
            (index) {
              return Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 90 / 100,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Row(
                              // Changed to simple Row
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      4 /
                                      100,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        3 /
                                        100),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          30 /
                                          100, // Reduced width
                                      height: 15,
                                      color: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100),
                ],
              );
            },
          ),
        ),
        // User info shimmer
      ],
    ),
  );
}
