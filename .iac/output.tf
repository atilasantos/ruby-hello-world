# Start Generation Here
output "lovevery_app_notes" {
  value = helm_release.lovevery-hello.metadata[0].notes
}
