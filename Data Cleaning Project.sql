/* Cleaning Data in SQL Queries */

select *
from [dbo].[NashvilleHousing]

--Standardize Date Format

select SaleDate, CONVERT(Date, SaleDate)
from [dbo].[NashvilleHousing]

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Or this option if the above is not working

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data
select PropertyAddress
from [dbo].[NashvilleHousing]

select *
from [dbo].[NashvilleHousing]
where PropertyAddress is null

select *
from [dbo].[NashvilleHousing]
order by ParcelID -- Property Address has a distinct Parcel ID

select data1.ParcelID, data1.PropertyAddress, data2.ParcelID, data2.PropertyAddress
from [dbo].[NashvilleHousing] as data1
Join [dbo].[NashvilleHousing] as data2
on data1.ParcelID = data2.ParcelID
and data1.UniqueID <> data2.UniqueID
Where data1.PropertyAddress is null

select data1.ParcelID, data1.PropertyAddress, data2.ParcelID, data2.PropertyAddress, ISNULL(data1.PropertyAddress, data2.PropertyAddress)
from [dbo].[NashvilleHousing] as data1
Join [dbo].[NashvilleHousing] as data2
on data1.ParcelID = data2.ParcelID
and data1.UniqueID <> data2.UniqueID
Where data1.PropertyAddress is null

UPDATE data1
SET PropertyAddress = ISNULL(data1.PropertyAddress, data2.PropertyAddress)
from [dbo].[NashvilleHousing] as data1
Join [dbo].[NashvilleHousing] as data2
on data1.ParcelID = data2.ParcelID
and data1.UniqueID <> data2.UniqueID
Where data1.PropertyAddress is null

-- Breaking out address into Individual Columns

select PropertyAddress
from [dbo].[NashvilleHousing]

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
from [dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

--Another option to separate address
Select OwnerAddress
from [dbo].[NashvilleHousing]

Select
Parsename(replace(OwnerAddress,',','.'),3),
Parsename(replace(OwnerAddress,',','.'),2),
Parsename(replace(OwnerAddress,',','.'),1)
from [dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = Parsename(replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitCity = Parsename(replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitState = Parsename(replace(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in Sold as Vacant field


Select Distinct(SoldasVacant)
from [dbo].[NashvilleHousing]

Select Distinct(SoldasVacant), Count(SoldasVacant)
from [dbo].[NashvilleHousing]
Group by SoldasVacant
Order by 2

Select SoldasVacant,
case when SoldasVacant  = 'Y' then 'Yes'
	 when SoldasVacant = 'N' then 'No'
	 else SoldasVacant
	 END
from [dbo].[NashvilleHousing]

Update NashvilleHousing
SET SoldasVacant = case when SoldasVacant  = 'Y' then 'Yes'
	 when SoldasVacant = 'N' then 'No'
	 else SoldasVacant
	 END

--Remove duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over( 
	Partition by ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 Order by 
					UniqueID
					) as row_num
from [dbo].[NashvilleHousing]
)
Select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over( 
	Partition by ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 Order by 
					UniqueID
					) as row_num
from [dbo].[NashvilleHousing]
)
Delete
from RowNumCTE
where row_num > 1

--Delete Unused Columns

select *
from [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN SaleDate