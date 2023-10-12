import openpyxl as px
import os

class ConvertXLSMtoXLSX():

    """
    Converts XLSM to XLSX
    """


    def convert_xlsm_to_xlsx(self, input_path, output_path):
        wb = px.load_workbook(filename=input_path, data_only=True)
        wb.save(output_path)


    def iterate_files(self, path):
        for file_name in os.listdir(path):
            file_path = os.path.join(path, file_name)
            if os.path.isfile(file_path):
                output_path = file_path.replace("xlsm", "xlsx")
                ConvertXLSMtoXLSX.convert_xlsm_to_xlsx(self, file_path, output_path)
                print("OLD FILE: ", file_path)
                print("CONVERTED FILE: ", output_path)
        return 200


path = "C:\\temp\\test\\"
instance = ConvertXLSMtoXLSX()
result = instance.iterate_files(path)
print(result)