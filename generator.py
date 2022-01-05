import pandas as pd


def transfer(cell, dtype):
    if dtype == 'object':
        # print("\'%s\'" % cell)
        return "\'%s\'" % str(cell).replace('\'', '\'\'')
    elif dtype == 'datetime64[ns]':
        # print(str(cell).split(' ')[0])
        return "\'%s\'" % str(cell).split(' ')[0]
    return (str(cell) + ' ').replace('.0 ', '').replace(' ', '')


oupfile = open("INSERT_GENE_RESULT.txt", 'w')
oupfile.write("USE [BUDT703_Project_%s_%s];\n\n"
              % (input("Please enter the section number: "), input("Please enter the team number: ")))
oupfile.write("BEGIN" + " TRANSACTION;\n\nSET ANSI_WARNINGS OFF;\n\n")
Name = input("Please enter the name of the project workspace: ")  # Master_Lee's
excel_file = pd.ExcelFile('~/Downloads/Entity_Attribute Tracking (2).xlsx')
mark = {}
version = input("Generating Start:\n"
                "Generating INSERT for empty tables? (0 for Yes, other number for Generating Version) ")
if version != '0':
    mark_file = open("Row_Mark_%s_%d.txt" % (Name, int(version)-1), 'r')
    try:
        mark = eval(mark_file.read())
        print(mark)
    except:
        pass
    mark_file.close()
mark_file = open("Row_Mark_%s_%s.txt" % (Name, version), 'w')
mark_file.seek(0)
mark_file.write('{')
# print(excel_file.sheet_names)
for sheet in excel_file.sheet_names:
    df = pd.read_excel(excel_file, sheet)
    mark_file.write("\'%s\' : %d,\n" % (sheet.replace(' ', ''), len(df.index)))
    if sheet.replace(' ', '') in mark:
        t = mark[sheet.replace(' ', '')]
    else:
        t = 0
    if len(df.index)-t == 0:
        continue
    oupfile.write(("INSERT" + " INTO [%s.%s] VALUES\n") % (Name, sheet.replace(' ', '')))
    for row in range(t, len(df.index)):
        s = '('
        for col in df.columns:
            # print(df[col].dtypes)
            s += transfer(df.loc[row, col], df[col].dtypes) + ', '
        s = s[:-2] + ')'
        if row == len(df.index) - 1:
            s += ';'
        else:
            s += ','
        oupfile.write(s.replace('nan', '') + "\n")
    oupfile.write("\n")
for sheet in excel_file.sheet_names:
    oupfile.write("SELECT" + " * FROM [%s.%s]\n" % (Name, sheet.replace(' ', '')))
oupfile.write("\nSET ANSI_WARNINGS ON;\n\nCOMMIT;\n")
mark_file.seek(mark_file.tell() - 2)
mark_file.write('}')
mark_file.close()
oupfile.close()
