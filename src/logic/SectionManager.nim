import Section, sequtils

# SectionManager has many Sections
# Section has many Slots
type
  SectionManager* = ref object
    sections: seq[Section]
    current_section: int
    file_content_section: int # с какой секции начинается контент

proc newSectionManager(start_section: Section): SectionManager =
  result = SectionManager()
  result.current_section = 0
  result.file_content_section = -1
  result.sections.add(start_section)


# CONTROL
func remove_all_from_n*(section_manager: SectionManager, n: int) = 
  assert section_manager.sections.len - 1 >= n
  for i in 0..n:
    section_manager.sections.del(section_manager.sections.len() - 1)

# UTILS
proc pretty_print*(sectionManager: SectionManager) =
  for i, section in sectionManager.sections:
    echo "section №", i
    section.pretty_print()
    
# TESTS
func construct_test_section_manager(): SectionManager =
  var sas: seq[Section]
  for i in 1..3:
    sas.add construct_test_section(i)
  result = newSectionManager(construct_test_section(0))
  result.sections.add sas
  assert result.sections.len == 4


proc test_remove_all_from_n() =
  var section_manager = construct_test_section_manager()
  section_manager.remove_all_from_n 1
  section_manager.pretty_print()
  assert section_manager.sections.len == 2

when isMainModule:
  test_remove_all_from_n()