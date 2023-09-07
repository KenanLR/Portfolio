/*

Cleaning Data in SQL Queries

*/

SELECT * FROM nashvillehousing;

ALTER TABLE nashvillehousing
RENAME column ï»¿UniqueID
TO UniqueID;

UPDATE
	nashvillehousing
SET
	OwnerName = CASE OwnerName WHEN '' THEN NULL ELSE OwnerName END,
	OwnerAddress = CASE OwnerAddress WHEN '' THEN NULL ELSE OwnerAddress END,
	TaxDistrict = CASE TaxDistrict WHEN '' THEN NULL ELSE TaxDistrict END;
    
-- Standardize Date Format

SELECT SaleDate FROM nashvillehousing;
SELECT 
    SaleDateConverted, CONVERT( SaleDate , DATE)
FROM
    portfolioproject.Nashvillehousing;
    
UPDATE 
	Nashvillehousing 
SET 
    SaleDate = CONVERT(SaleDate,DATE);

ALTER TABLE nashvillehousing
ADD SaleDateConverted Date;

UPDATE nashvillehousing
SET SaleDateConverted = CONVERT(SaleDate,Date);

-- Populate Property Address Data

UPDATE
	nashvillehousing
SET
	PropertyAddress = CASE PropertyAddress WHEN '' THEN NULL ELSE PropertyAddress END;

SELECT 
    *
FROM
    portfolioproject.Nashvillehousing
-- WHERE PropertyAddress is null
order by ParcelID;

ALTER TABLE nashvillehousing
MODIFY ParcelID text null,
MODIFY LegalReference text null;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
From portfolioproject.nashvillehousing a
JOIN portfolioproject.nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null;


Update portfolioproject.nashvillehousing a
JOIN portfolioproject.nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress) 
WHERE a.PropertyAddress is null;

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT 
    PropertyAddress
FROM
    portfolioproject.Nashvillehousing
-- WHERE PropertyAddress is null
-- order by ParcelID
;


SELECT 
SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1) as Address
, SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') +1, length(PropertyAddress)) as Address
From Portfolioproject.nashvillehousing;

ALTER TABLE nashvillehousing
ADD PropertySplitAddress varchar(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1);

ALTER TABLE nashvillehousing
ADD PropertySplitCity varchar(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') +1, length(PropertyAddress));

Select *
From portfolioproject.nashvillehousing;

Select OwnerAddress
From portfolioproject.nashvillehousing;

Select
substring_index(OwnerAddress, ',', 1) as Street_Address,
substring_index(substring_index(OwnerAddress, ',', 2), ',', -1) as City,
substring_index(OwnerAddress, ',', -1) as State
FROM portfolioproject.nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress varchar(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = substring_index(OwnerAddress, ',', 1);

ALTER TABLE nashvillehousing
ADD OwnerSplitCity varchar(255);

UPDATE nashvillehousing
SET OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE nashvillehousing
ADD OwnerSplitState varchar(255);

UPDATE nashvillehousing
SET OwnerSplitState = substring_index(OwnerAddress, ',', -1);

-- Change Y and N to Yes and No in "Sold as Vacant' field

Select Distinct(SoldasVacant), Count(SoldAsVacant)
 From nashvillehousing
 group by SoldAsVacant
 order by 2 desc;
 
 SELECT SoldAsVacant
 , CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM portfolioproject.nashvillehousing;

UPDATE	nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END;

-- Remove Duplicates 

WITH RowNumCTE
AS(
SELECT *,
	row_number() OVER (
	partition by ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 order by
                 UniqueID
                 ) as row_num
FROM nashvillehousing
)
-- DELETE t1
SELECT *
FROM RowNumCTE /* nashvillehousing t1 inner join RowNumCTE t2
on t2.UniqueID = t1.UniqueID */
Where row_num > 1
order by PropertyAddress;

-- Delete Unused Columns
 
ALTER TABLE portfolioproject.nashvillehousing
DROP COLUMN OwnerAddress;

ALTER TABLE portfolioproject.nashvillehousing
DROP COLUMN TaxDistrict;

ALTER TABLE portfolioproject.nashvillehousing
DROP COLUMN PropertyAddress;

ALTER TABLE portfolioproject.nashvillehousing
DROP COLUMN SaleDate;