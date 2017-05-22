USE AX2012_model;
GO

SELECT
	ModelElement.ElementType, ModelElement.ElementHandle, ModelElement.Name, ModelElement.Origin,
	ModelElementData.CREATEDDATETIME, ModelElementData.CREATEDBY, ModelElementData.MODIFIEDDATETIME,
	ModelElementData.MODIFIEDBY, parent.ElementType AS [Parent type], Parent.Name AS [Parent name]
	FROM ModelElement
	INNER JOIN ModelElementData
		ON ModelElementData.ElementHandle = ModelElement.ElementHandle
	LEFT OUTER JOIN ModelElementData AS ParentData
		ON ParentData.ElementHandle = ModelElement.ParentHandle
	INNER JOIN ModelElement AS Parent
		ON Parent.ElementHandle	= ParentData.ElementHandle
	WHERE ModelElement.ElementType = 42 -- UtilElementType == Tables
		AND ModelElement.Name LIKE '%SALESID%'
		AND ModelElementData.LayerId > 5 -- Customizations only. Values are in Layer table