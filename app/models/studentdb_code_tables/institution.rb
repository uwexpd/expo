# Institution Codes
class Institution < StudentInfo
  set_table_name "sys_tbl_02_ed_inst_info"
#  set_primary_keys :table_type, :table_key
  set_primary_key :table_key
  
  def <=>(o)
    name <=> o.name rescue 0
  end
  
  def id
    read_attribute(:table_key).to_i
  end
  
  def name
    college_names = {
      "THE EVERGREEN ST COLL" => "The Evergreen State College",
      "NORTH SEATTLE CC"      => "North Seattle Community College",
      "SEATTLE CENTRAL CC"    => "Seattle Central Community College",
      "SEATTLE PACIFIC UNIV"  => "Seattle Pacific University",
      "SEATTLE UNIV"          => "Seattle University",
      "CLEVELAND STATE UNIV"  => "Cleveland State University",
      "EARLHAM COLL"          => "Earlham College",
      "JOHN JAY C CRIM JUST"  => "John Jay College of Criminal Justice",
      "UNIV NTHRN COLORADO"   => "University of Northern Colorado",
      "WASH STATE UNIV"       => "Washington State University",
      "UNIV WISC OSHKOSH"     => "University Wisconsin, Oshkosh",
      "PORTLAND ST UNIV"      => "Portland State University",
      "WESTERN WASH UNIV"     => "Western Washington University",
      "UNIV CALIF DAVIS"      => "University of California, Davis",
      "EVERETT COMM COLL"     => "Everett Community College",
      "BOISE ST UNIV"         => "Boise State University",
      "EDMONDS COMM COLL"     => "Edmonds Community College",
      "UNIV OF PUGET SOUND"   => "University of Puget Sound"
      }
    college_names[institution_name.strip] || institution_name.strip.titleize
  end
  
end
