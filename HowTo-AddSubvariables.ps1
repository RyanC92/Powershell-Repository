#Howto - Add Subvariables - Any of these would work

# properties, via add-member (also supports methods, scripts, etc)            
$foo = new-object psobject            
$foo | add-member noteproperty name1 value1            
$foo | add-member noteproperty name2 value2            
            
            
# properties, via select-object or format-table            
$foo = new-object psobject |            
    select @{Name="name1"; Expression={"value1"}},            
           @{Name="name2"; Expression={"value2"}}            
            
            
# hashtable, native syntax            
$foo = @{name1="value1"            
         name2="value2"}            
            
            
# properties, via hashtable (v2.0 only)            
$foo = new-object psobject -Property @{            
    name1="value1"            
    name2="value2"            
}            
            
            
# properties, via dynamic compilation (v2.0 only - also supports methods)            
add-type @'
public class FooType
{
    public string name1 = "value1";
    public string name2 = "value2";
}
'@            
$foo = new-object FooType