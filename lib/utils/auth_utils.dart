String emailFromUsername(String username) {
  // ensure no stray spaces
  final u = username.trim();
  return '$u@coldapp.com';
}
